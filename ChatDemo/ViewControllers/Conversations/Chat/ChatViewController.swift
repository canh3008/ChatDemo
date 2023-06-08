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

    private var mediaAlertController: MediaAlertViewController?
    private let disposeBag = DisposeBag()
    private let selectionLimitPhoto = 1
    private let viewModel: ChatViewModel
    private var messages = [Message]() {
        didSet {
            messagesCollectionView.reloadData()
        }
    }
    private var selfSender: Sender?
    private var newMessageSubject = PublishSubject<String>()
    private var photosSubject = PublishSubject<[UIImage]>()

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
        setupInputButton()
    }

    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            guard let self = self else {
                return
            }
            self.mediaAlertController = nil
            self.mediaAlertController = MediaAlertViewController(title: "Attach Media",
                                                                 message: "What would you like to attach?",
                                                                 style: .actionSheet,
                                                                 selectionLimit: self.selectionLimitPhoto)
            self.mediaAlertController?.delegate = self
            self.mediaAlertController?.showAlert(animated: false)
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)

    }

    private func bindingData() {
        let input = ChatViewModel.Input(newMessage: newMessageSubject, photos: photosSubject)

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
            .sendPhotoSuccess
            .drive { isSuccess in
                print("zzzzzzzzzzz is send photo", isSuccess)
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

    deinit {
        print("Deinit: ", String(describing: Self.self))
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

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.setImage(with: imageUrl)
        default:
            break
        }
    }
}

extension ChatViewController: MediaAlertViewControllerDelegate {
    func didSelectedPhotos(view: MediaAlertViewController, photos: [UIImage]) {
//        self.photosSubject.onNext(photos)
    }

}
