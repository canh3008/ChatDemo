//
//  ConversationsViewModel.swift
//  ChatDemo
//
//  Created by Duc Canh on 03/05/2023.
//

import Foundation
import RxCocoa
import RxSwift

class ConversationsViewModel: BaseViewModel, ViewModelTransformable {

    private let saveAccountManager: SaveAccountManager
    private var requestSubject = BehaviorRelay<String?>(value: nil)

    init(saveAccountManager: SaveAccountManager = SaveAccountManager()) {
        self.saveAccountManager = saveAccountManager
    }

    func transform(input: Input) -> Output {
        self.requestSubject.accept(getSafeCurrentEmail())
        triggerEvent()
        return Output(allConversations: getAllConversation())
    }

    private func getAllConversation() -> Driver<[Conversation]> {

        return requestSubject
            .compactMap({ $0 })
            .flatMapLatest({ email -> Observable<[Conversation]> in
            return DatabaseManager
                .shared
                .getAllConversations(for: email)
                .mapGetResultValue()
        })
            .asDriverOnErrorJustComplete()
    }

    @objc private func recallGetAllConversation() {
        self.requestSubject.accept(getSafeCurrentEmail())
    }

    private func triggerEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recallGetAllConversation),
                                               name: NSNotification.Name(rawValue: "login_success"),
                                               object: nil)
    }

    private func getSafeCurrentEmail() -> String {
        saveAccountManager.getData(key: .email)
            .replacingOccurrences(of: "@", with: "-")
            .replacingOccurrences(of: ".", with: "-")
    }
}

extension ConversationsViewModel {
    struct Input {

    }

    struct Output {
        let allConversations: Driver<[Conversation]>
    }
}
