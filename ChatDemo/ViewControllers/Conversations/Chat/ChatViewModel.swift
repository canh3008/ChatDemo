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

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

extension MessageKind {
    var description: String {
        switch self {
        case .text:
            return "text"
        case .attributedText:
            return "attributed_text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .location:
            return "location"
        case .emoji:
            return "emoji"
        case .audio:
            return "audio"
        case .contact:
            return "contact"
        case .linkPreview:
            return "linkPreview"
        case .custom:
            return "custom"
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
    private var selfSender: Sender!
    private let dateString = Date().dateString()
    private var otherUserEmail = ""
    private var currentEmail = ""
    private var messageId = ""

    init(user: User,
         isNewConversation: Bool = false,
         id: String = "",
         saveAccountManager: SaveAccountManager = SaveAccountManager()) {
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
                      updateLatestMessageSuccess: updateLatestMessageSuccess)
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
}

extension ChatViewModel {
    struct Input {
        let newMessage: Observable<String>
    }

    struct Output {
        let nameUser: Driver<String>
        let isSendMessageSuccess: Driver<Bool>
        let allMessages: Driver<[Message]>
        let sender: Driver<Sender>
        let updateLatestMessageSuccess: Driver<Bool>
    }
}
