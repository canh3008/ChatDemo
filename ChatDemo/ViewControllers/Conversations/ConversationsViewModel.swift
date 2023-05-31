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
    private var requestSubject = PublishSubject<String>()

    init(saveAccountManager: SaveAccountManager = SaveAccountManager()) {
        self.saveAccountManager = saveAccountManager
    }

    func transform(input: Input) -> Output {
        self.requestSubject.onNext(getSafeCurrentEmail())
        triggerEvent()
        return Output(allConversations: getAllConversation())
    }

    private func getAllConversation() -> Driver<[Conversation]> {

        return requestSubject
            .flatMapLatest({ email -> Observable<[Conversation]> in
            return DatabaseManager
                .shared
                .getAllConversations(for: email)
                .mapGetResultValue()
        })
            .asDriverOnErrorJustComplete()
    }

    @objc private func recallGetAllConversation() {
        self.requestSubject.onNext(getSafeCurrentEmail())
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
