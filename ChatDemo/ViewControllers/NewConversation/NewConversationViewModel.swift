//
//  NewConversationViewModel.swift
//  ChatDemo
//
//  Created by Duc Canh on 05/05/2023.
//

import Foundation
import RxSwift
import RxCocoa
import MessageKit

struct Conversation: Codable {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage

    enum CodingKeys: String, CodingKey {
        case id, name
        case otherUserEmail = "other_user_email"
        case latestMessage = "latest_message"
    }
}

struct LatestMessage: Codable {
    let date: String
    let text: String
    let isRead: Bool

    enum CodingKeys: String, CodingKey {
        case date
        case isRead = "is_read"
        case text = "message"
    }
}

class NewConversationViewModel: BaseViewModel, ViewModelTransformable {

    private let saveAccountManager: SaveAccountManager

    init(saveAccountManager: SaveAccountManager = SaveAccountManager()) {
        self.saveAccountManager = saveAccountManager
    }

    func transform(input: Input) -> Output {

        let getUsers: Observable<[User]> = DatabaseManager
            .shared
            .getAllUsers()
            .mapGetResultValue()

        let filterUser = Observable
            .combineLatest(input.textSearch.filter({ !$0.replacingOccurrences(of: " ", with: "").isEmpty }), getUsers)
            .map { (searchText, users) -> [User] in
                let resultSearch = users
                    .filter({ $0.name.lowercased().hasPrefix(searchText.lowercased()) })
                return resultSearch
            }

        let allUserCurrent = input
            .textSearch
            .filter({ $0.replacingOccurrences(of: " ", with: "").isEmpty })
            .withLatestFrom(getUsers)

        let users = Observable.merge(getUsers, filterUser, allUserCurrent)

        return Output(allUsers: users.asDriverOnErrorJustComplete())
    }

}

extension NewConversationViewModel {
    struct Input {
        let textSearch: Observable<String>
    }

    struct Output {
        let allUsers: Driver<[User]>
    }
}
