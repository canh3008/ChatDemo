//
//  DatabaseManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 28/04/2023.
//

import Foundation
import FirebaseDatabase
import RxSwift
import MessageKit

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let token: String?
    let image: UIImage?

    func convertEmail() -> String {
        return emailAddress
            .replacingOccurrences(of: "@", with: "-")
            .replacingOccurrences(of: ".", with: "-")

    }

    var pictureData: Data {
        return image?.pngData() ?? Data()
    }

    var profilePictureFileName: String {
        ///  canh-gmail-com_profile_picture.png
        return "\(convertEmail())_profile_picture.png"
    }

    var fullName: String {
        return firstName + " " + lastName
    }
}

struct User: Codable {
    let name: String
    let email: String

    var safeEmail: String {
        return email
            .replacingOccurrences(of: "@", with: "-")
            .replacingOccurrences(of: ".", with: "-")
    }
}

struct MessageModel: Codable {
    let name: String
    let isRead: Bool
    let messageId: String
    let content: String
    let senderEmail: String
    let type: String
    let dateString: String

    enum CodingKeys: String, CodingKey {
        case name, content, type
        case isRead = "is_read"
        case messageId = "id"
        case senderEmail = "sender_email"
        case dateString = "date"
    }

    func asMessage() -> Message {
        let sender = Sender(photoURL: "",
                            senderId: senderEmail,
                            displayName: name)
        let kind = MessageKindText(rawValue: type) ?? .text
        var finalKind: MessageKind = .text(content)

        switch kind {
        case .text:
            finalKind = .text(content)
        case .attributedText:
            break
        case .photo:
            let media = Media(url: URL(string: content),
                              image: nil,
                              placeholderImage: UIImage(named: "image_waiting") ?? UIImage(),
                              size: CGSize(width: UIScreen.main.bounds.width / 3, height: 200))
            finalKind = .photo(media)
        case .video:
            break
        case .location:
            break
        case .emoji:
            break
        case .audio:
            break
        case .contact:
            break
        case .linkPreview:
            break
        case .custom:
            break
        }
        return Message(sender: sender,
                       messageId: messageId,
                       sentDate: dateString.dateDefaultFormatter(),
                       kind: finalKind)
    }
}

enum EmailType {
    case other(String)
    case current(String)

    var getEmail: String {
        switch self {
        case .other(let string):
            return string
                .replacingOccurrences(of: "@", with: "-")
                .replacingOccurrences(of: ".", with: "-")
        case .current(let string):
            return string
                .replacingOccurrences(of: "@", with: "-")
                .replacingOccurrences(of: ".", with: "-")
        }
    }
}
class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    private let disposeBag = DisposeBag()
    private let storageManager: StorageManager
    private let loadingService: LoadingFeature
    private let saveAccountManager: SaveAccountManager

    init(storageManager: StorageManager = StorageManager(),
         loadingService: LoadingFeature = LoadingService(),
         saveAccountManager: SaveAccountManager = SaveAccountManager()) {
        self.storageManager = storageManager
        self.loadingService = loadingService
        self.saveAccountManager = saveAccountManager
    }

}

extension DatabaseManager {

    func userExists(with email: String, completion: @escaping (Bool) -> Void) {
        database.child(email).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    /// Insert a new user to database
    func insertUser(with user: ChatAppUser) {
        userExists(with: user.convertEmail()) { [weak self] isExist in
            guard let self = self else {
                return
            }
            if !isExist {
                self.database.child(user.convertEmail()).setValue(["firstName": user.firstName,
                                                                   "lastName": user.lastName
                                                                   ],
                                                                  withCompletionBlock: { error, _ in
                    guard error == nil else {
                        return
                    }
                    // upload Image to Firebase
                    self.uploadProfilePicture(user: user)
                    self.addAllUserToDatabase(user: user)
                })
            }
        }
    }

    private func uploadProfilePicture(user: ChatAppUser) {
        self.storageManager
            .uploadProfilePicture(with: user.pictureData, fileName: user.profilePictureFileName)
            .subscribe(onNext: { result in
                switch result {
                case .success(let url):
                    print("zzzzzzzzzz url", url)
                    UserDefaults.standard.set(url, forKey: "profile_picture_url")
                case .failed:
                    print("Fail to upload profile picture to Firebase")
                }
            })
            .disposed(by: self.disposeBag)
    }

    private func addAllUserToDatabase(user: ChatAppUser) {
        database.child("users").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else {
                return
            }
            var newCollection: [[String: String]] = [[:]]
            if var usersCollection = snapshot.value as? [[String: String]] {
                // append to user dictionary
                let newElement: [String: String] = ["name": user.fullName,
                                                    "email": user.convertEmail()
                                                   ]
                usersCollection.append(newElement)
                newCollection = usersCollection
            } else {
                // create user collection
                newCollection = [
                    ["name": user.fullName,
                     "email": user.convertEmail()
                    ]
                ]
            }
            self.database.child("users").setValue(newCollection) { error, _ in
                guard error == nil else {
                    print("Fail to create user collection")
                    return
                }
                print("Create user collection successfully")
            }
        }
    }

    func getAllUsers() -> Observable<Result<[User], String>> {
        loadingService.show()
        return Observable.create { observer -> Disposable in
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [[String: String]] else {
                    observer.onNext(.failed("Fail to get all users"))
                    return
                }
                guard var allUser: [User] = value.castToObject() else {
                    observer.onNext(.failed("Fail to get all user"))
                    return
                }
                let currentEmail = self.saveAccountManager.getData(key: .email)
                    .replacingOccurrences(of: "@", with: "-")
                    .replacingOccurrences(of: ".", with: "-")
                allUser.removeFirst(where: { $0.email == currentEmail})
                observer.onNext(.success(allUser))
                self.loadingService.hide()
            }
            return Disposables.create()
        }
    }

    fileprivate func updateForUserOther(_ observer: AnyObserver<Result<Bool, String>>, _ safeCurrentEmail: String, firstMessage: Message, otherUserEmail: String) {
        // update to other email
        let nameOtherEmail = saveAccountManager.getData(key: .fullName)
        let refOtherUser = self.database.child(otherUserEmail)
        refOtherUser.observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                observer.onNext(.failed("Fail to get user node"))
                return
            }
            let dateString = firstMessage.sentDate.dateString()
            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText:
                break
            case .photo:
                break
            case .video:
                break
            case .location:
                break
            case .emoji:
                break
            case .audio:
                break
            case .contact:
                break
            case .linkPreview:
                break
            case .custom:
                break
            }
            let conversationId = "conversations_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeCurrentEmail,
                "name": nameOtherEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            if var conversation = userNode["conversations"] as? [[String: Any]] {
                conversation.append(newConversationData)
                userNode["conversations"] = conversation
            } else {
                // conversation array doesn't exist
                // create it
                userNode["conversations"] = [
                    newConversationData
                ]
            }
            refOtherUser.setValue(userNode) { error, _ in
                guard error == nil else {
                    observer.onNext(.failed("Fail to create a new conversation"))
                    return
                }
                observer.onNext(.success(true))
            }
        }
    }

    func createNewConversation(with otherUserEmail: String,
                               name: String,
                               firstMessage: Message) -> Observable<Result<Bool, String>> {
        Observable.create { observer -> Disposable in
            let currentEmail = self.saveAccountManager.getData(key: .email)
            let safeCurrentEmail = currentEmail
                .replacingOccurrences(of: "@", with: "-")
                .replacingOccurrences(of: ".", with: "-")
            let ref = self.database.child(safeCurrentEmail)
            ref.observeSingleEvent(of: .value) { snapshot in
                guard var userNode = snapshot.value as? [String: Any] else {
                    observer.onNext(.failed("Fail to get user node"))
                    return
                }

                let conversationId = "conversations_\(firstMessage.messageId)"
                let newConversationData: [String: Any] = [
                    "id": conversationId,
                    "other_user_email": otherUserEmail,
                    "name": name,
                    "latest_message": self.createNewLastMessage(firstMessage: firstMessage)
                ]
                if var conversation = userNode["conversations"] as? [[String: Any]] {
                    conversation.append(newConversationData)
                    userNode["conversations"] = conversation
                } else {
                    // conversation array doesn't exist
                    // create it
                    userNode["conversations"] = [
                        newConversationData
                    ]
                }
                ref.setValue(userNode) { error, _ in
                    guard error == nil else {
                        observer.onNext(.failed("Fail to create a new conversation"))
                        return
                    }
                    let fullNameCurrent = self.saveAccountManager.getData(key: .fullName)
                    self.finishCreatingConversation(name: fullNameCurrent,
                                                    currentEmail: safeCurrentEmail,
                                                    conversationId: conversationId,
                                                    firstMessage: firstMessage) { isSuccess in
                        if isSuccess {
                            observer.onNext(.success(true))
                        } else {
                            observer.onNext(.failed("Fail to finish create conversation"))
                        }

                    }
                }
            }

            self.updateForUserOther(observer,
                                    safeCurrentEmail,
                                    firstMessage: firstMessage,
                                    otherUserEmail: otherUserEmail)

            return Disposables.create()
        }
    }

    private func createNewLastMessage(firstMessage: Message) -> [String: Any] {

        var lastMessage = ""

        switch firstMessage.kind {

        case .text(let message):
            lastMessage = message
        case .attributedText:
            break
        case .photo:
            break
        case .video:
            break
        case .location:
            break
        case .emoji:
            break
        case .audio:
            break
        case .contact:
            break
        case .linkPreview:
            break
        case .custom:
            break
        }

        let value: [String: Any] = [
            "date": firstMessage.sentDate.dateString(),
            "is_read": false,
            "message": lastMessage
        ]

        return value
    }

    func updateLastMessage(email type: EmailType, conversationId: String, firstMessage: Message) -> Observable<Result<Bool, String>> {
        Observable.create { observer -> Disposable in
            let ref = self.database.child(type.getEmail).child("conversations")
            ref.observeSingleEvent(of: .value) { snapshot in
                guard var conversations = snapshot.value as? [[String: Any]] else {
                    observer.onNext(.failed("Fail to get conversations"))
                    return
                }
                for (index, conversation) in conversations.enumerated() {
                    if let id = conversation["id"] as? String, id == conversationId {
                        var newConversation = conversation
                        newConversation["latest_message"] = self.createNewLastMessage(firstMessage: firstMessage)
                        conversations[index] = newConversation
                    }
                }
                ref.setValue(conversations) { error, _ in
                    guard error == nil else {
                        observer.onNext(.failed("Fail to set conversations"))
                        return
                    }
                    observer.onNext(.success(true))
                }
            }
            return Disposables.create()
        }
    }

    func getAllConversations(for email: String) -> Observable<Result<[Conversation], String>> {
        return Observable.create { observer -> Disposable in
            self.database.child("\(email)/conversations").observe(.value) { snapshot in
                guard let value = snapshot.value as? [[String: Any]],
                      let allConversation: [Conversation] = value.castToObject() else {
                    observer.onNext(.failed("Fail to get all conversation"))
                    return
                }
                observer.onNext(.success(allConversation))
            }
            return Disposables.create()
        }
    }

    func getAllMessagesForConversation(with id: String) -> Observable<Result<[Message], String>> {
        return Observable.create { observer -> Disposable in
            self.database.child("\(id)/messages").observe(.value) { snapshot in
                guard let value = snapshot.value as? [[String: Any]],
                      let allMessages: [MessageModel] = value.castToObject() else {
                    observer.onNext(.failed("Fail to get all conversation"))
                    return
                }
                let messages = allMessages.map({ $0.asMessage() })
                observer.onNext(.success(messages))
            }
            return Disposables.create()
        }
    }

    func sendMessage(to conversationId: String, message: Message) -> Observable<Result<Bool, String>> {
        let path = conversationId + "/messages"
        return Observable.create { observer -> Disposable in
            self.database.child(path).observeSingleEvent(of: .value) { snapshot, error in
                guard error == nil, var value = snapshot.value as? [[String: Any]] else {
                    observer.onNext(.failed(error?.description ?? "Nil"))
                    return
                }
                var messageText = ""
                switch message.kind {
                case .text(let message):
                    messageText = message
                case .attributedText:
                    break
                case .photo(let media):
                    messageText = media.url?.absoluteString ?? ""
                case .video:
                    break
                case .location:
                    break
                case .emoji:
                    break
                case .audio:
                    break
                case .contact:
                    break
                case .linkPreview:
                    break
                case .custom:
                    break
                }
                let currentEmail = self.saveAccountManager.getData(key: .email)
                    .replacingOccurrences(of: "@", with: "-")
                    .replacingOccurrences(of: ".", with: "-")

                let name = self.saveAccountManager.getData(key: .fullName)
                let newMessage: [String: Any] = [
                    "id": message.messageId,
                    "type": message.kind.description,
                    "content": messageText,
                    "date": message.sentDate.dateString(),
                    "sender_email": currentEmail,
                    "is_read": false,
                    "name": name
                ]
                value.append(newMessage)
                self.database.child(path).setValue(value) { error, _ in
                    guard error == nil else {
                        observer.onNext(.failed(error?.localizedDescription ?? "Nil"))
                        return
                    }
                    observer.onNext(.success(true))
                }
            }
            return Disposables.create()
        }
    }

    private func finishCreatingConversation(name: String,
                                            currentEmail: String,
                                            conversationId: String,
                                            firstMessage: Message,
                                            completion: @escaping ((Bool) -> Void)) {
        var messageText = ""
        switch firstMessage.kind {
        case .text(let message):
            messageText = message
        case .attributedText:
            break
        case .photo:
            break
        case .video:
            break
        case .location:
            break
        case .emoji:
            break
        case .audio:
            break
        case .contact:
            break
        case .linkPreview:
            break
        case .custom:
            break
        }
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.description,
            "content": messageText,
            "date": firstMessage.sentDate.dateString(),
            "sender_email": currentEmail,
            "is_read": false,
            "name": name
        ]
        let value: [String: Any] = [
            "messages": [
                collectionMessage
                ]
        ]
        database.child("\(conversationId)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    func getInfoCurrentUser(completion: @escaping ((String) -> Void)) {
        let email = saveAccountManager.getData(key: .email)
            .replacingOccurrences(of: "@", with: "-")
            .replacingOccurrences(of: ".", with: "-")
        database.child(email).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
            let firstName = value["firstName"] as? String,
            let lastName = value["lastName"] as? String else {
                return
            }
            let fullName = firstName + " " + lastName
            completion(fullName)
        }
    }
}
