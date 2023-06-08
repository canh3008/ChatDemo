//
//  ChatViewModel.swift
//  ChatDemo
//
//  Created by Duc Canh on 03/05/2023.
//

import Foundation
import MessageKit
import RxSwift
import RxCocoa

struct InfoPhoto {
    let data: Data
    let fileName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

enum MessageKindText: String {
    case text = "text"
    case attributedText = "attributed_text"
    case photo = "photo"
    case video = "video"
    case location = "location"
    case emoji = "emoji"
    case audio = "audio"
    case contact = "contact"
    case linkPreview = "linkPreview"
    case custom = "custom"
}

extension MessageKind {
    var description: String {
        switch self {
        case .text:
            return MessageKindText.text.rawValue
        case .attributedText:
            return MessageKindText.attributedText.rawValue
        case .photo:
            return MessageKindText.photo.rawValue
        case .video:
            return MessageKindText.video.rawValue
        case .location:
            return MessageKindText.location.rawValue
        case .emoji:
            return MessageKindText.emoji.rawValue
        case .audio:
            return MessageKindText.audio.rawValue
        case .contact:
            return MessageKindText.contact.rawValue
        case .linkPreview:
            return MessageKindText.linkPreview.rawValue
        case .custom:
            return MessageKindText.custom.rawValue
        }
    }
}

struct Sender: SenderType, Codable {
    var photoURL: String
    var senderId: String
    var displayName: String

}

class ChatViewModel: BaseViewModel, ViewModelTransformable {

    private let user: User
    private let isNewConversation: Bool
    private let saveAccountManager: SaveAccountManager
    private let storageManager: StorageManager
    private var selfSender: Sender!
    private let dateString = Date().dateString()
    private var otherUserEmail = ""
    private var currentEmail = ""
    private var messageId = ""

    init(user: User,
         isNewConversation: Bool = false,
         id: String = "",
         saveAccountManager: SaveAccountManager = SaveAccountManager(),
         storageManager: StorageManager = StorageManager()) {
        self.user = user
        self.messageId = id
        self.otherUserEmail = user.safeEmail
        self.isNewConversation = isNewConversation
        self.saveAccountManager = saveAccountManager
        currentEmail = saveAccountManager.getData(key: .email)
            .replacingOccurrences(of: "@", with: "-")
            .replacingOccurrences(of: ".", with: "-")
        let fullName = saveAccountManager.getData(key: .fullName)
        self.selfSender = Sender(photoURL: "",
                                 senderId: currentEmail,
                                 displayName: fullName)
        self.storageManager = storageManager
    }

    func transform(input: Input) -> Output {
        let createNewConversation: Observable<Bool> = input
            .newMessage
            .filter({ _ in self.isNewConversation })
            .map({ self.createMessage(text: $0) })
            .flatMapLatest { [weak self] message -> Observable<Result<Bool, String>> in
                guard let self = self else {
                    return .empty()
                }
                return DatabaseManager.shared.createNewConversation(with: self.otherUserEmail,
                                                                    name: self.user.name,
                                                                    firstMessage: message)
            }
            .mapGetResultValue()

         let message = input
            .newMessage
            .filter({ _ in !self.isNewConversation })
            .map({ self.createMessage(text: $0) })
            .share()

        let sendMessage: Observable<Bool> = message
            .flatMapLatest { [weak self] message -> Observable<Result<Bool, String>> in
                guard let self = self else {
                    return .empty()
                }
                return DatabaseManager.shared.sendMessage(to: self.messageId, message: message)
            }
            .mapGetResultValue()

        let updateLastMessageCurrentEmail: Observable<Bool> = message
            .flatMapLatest { [weak self] message -> Observable<Result<Bool, String>> in
                guard let self = self else {
                    return .empty()
                }
                return DatabaseManager.shared.updateLastMessage(email: .current(self.currentEmail),
                                                                conversationId: self.messageId,
                                                                firstMessage: message)
            }
            .mapGetResultValue()

        let updateLastMessageOtherEmail: Observable<Bool> = message
            .flatMapLatest { [weak self] message -> Observable<Result<Bool, String>> in
                guard let self = self else {
                    return .empty()
                }
                return DatabaseManager.shared.updateLastMessage(email: .other(self.otherUserEmail),
                                                                conversationId: self.messageId,
                                                                firstMessage: message)
            }
            .mapGetResultValue()

        let updateLatestMessageSuccess = Observable.zip(updateLastMessageOtherEmail, updateLastMessageCurrentEmail)
            .asDriverOnErrorJustComplete()
            .map({ $0 && $1 })

        let uploadMessagePhotos = input.photos
            .map({ $0.map({ InfoPhoto(data: $0.pngData() ?? Data(), fileName: self.createPhotoId()) }) })
            .flatMapLatest { [weak self] infos -> Observable<Result<[String], String>> in
                guard let self = self else {
                    return .empty()
                }

                return self.storageManager.uploadMessagePhotos(data: infos)
            }
            .share()

        let uploadMessagePhotosSuccess: Observable<[String]> = uploadMessagePhotos
            .mapGetResultValue()

        let sendPhoto = uploadMessagePhotosSuccess
            .map({ self.createPhotoMessages(with: $0) })
            .compactMap({ $0.first })
            .flatMapLatest { message -> Observable<Result<Bool, String>> in
                DatabaseManager.shared.sendMessage(to: self.messageId, message: message)
            }

        let sendPhotoSuccess = sendPhoto
            .mapGetResultSuccess()
            .asDriverOnErrorJustComplete()

        let getAllMessages: Driver<[Message]> = DatabaseManager
            .shared
            .getAllMessagesForConversation(with: self.messageId)
            .mapGetResultValue()
            .asDriverOnErrorJustComplete()

        let sender = Driver.just(selfSender)
            .compactMap({ $0 })

        let isSendMessageSuccess = Observable.merge(createNewConversation, sendMessage).asDriverOnErrorJustComplete()
        
        return Output(nameUser: Driver.just(user.name).map({ $0.capitalized }),
                      isSendMessageSuccess: isSendMessageSuccess,
                      allMessages: getAllMessages,
                      sender: sender,
                      updateLatestMessageSuccess: updateLatestMessageSuccess,
                      sendPhotoSuccess: sendPhotoSuccess)
    }

    private func createMessageId() -> String {
        // date, otherUserEmail, senderEmail, randomInt
        return "\(otherUserEmail)_\(currentEmail)_\(dateString)"
    }

    private func createMessage(text: String) -> Message {
        return Message(sender: self.selfSender,
                       messageId: createMessageId(),
                       sentDate: Date(),
                       kind: .text(text))
    }

    private func createPhotoId() -> String {
        return "message_photo" + createMessageId()
    }

    private func createPhotoMessages(with urls: [String]) -> [Message] {
        urls.map({ Message(sender: self.selfSender,
                           messageId: createMessageId(),
                           sentDate: Date(),
                           kind: .photo(Media(url: URL(string: $0),
                                              image: nil,
                                              placeholderImage: UIImage(),
                                              size: .zero))) })
    }
}

extension ChatViewModel {
    struct Input {
        let newMessage: Observable<String>
        let photos: Observable<[UIImage]>
    }

    struct Output {
        let nameUser: Driver<String>
        let isSendMessageSuccess: Driver<Bool>
        let allMessages: Driver<[Message]>
        let sender: Driver<Sender>
        let updateLatestMessageSuccess: Driver<Bool>
        let sendPhotoSuccess: Driver<Bool>
    }
}
