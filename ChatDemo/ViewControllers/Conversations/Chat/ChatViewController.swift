//
//  ChatViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 03/05/2023.
//

import UIKit
import MessageKit
import RxSwift
import RxCocoa
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: ChatViewModel
    private var messages = [Message]() {
        didSet {
            messagesCollectionView.reloadData()
        }
    }
    private var selfSender: Sender?
    private var newMessageSubject = PublishSubject<String>()

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        bindingData()
    }

    private func bindingData() {
        let input = ChatViewModel.Input(newMessage: newMessageSubject)

        let output = viewModel.transform(input: input)

        output
            .nameUser
            .drive(rx.title)
            .disposed(by: disposeBag)

        output
            .isSendMessageSuccess
            .drive { isSuccess in
                print("zzzzzzzzzzz is send message", isSuccess)
            }
            .disposed(by: disposeBag)

        output.updateLatestMessageSuccess
            .drive { isSuccess in
                print("zzzzzzzzzzz is update message", isSuccess)
            }
            .disposed(by: disposeBag)

        output
            .allMessages
            .drive { [weak self] messages in
                self?.messages = messages
            }
            .disposed(by: disposeBag)

        output
            .sender
            .drive { [weak self] sender in
                self?.selfSender = sender
            }
            .disposed(by: disposeBag)
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        newMessageSubject.onNext(text)
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        selfSender ?? Sender(photoURL: "", senderId: "", displayName: "")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        messages.count
    }
}
