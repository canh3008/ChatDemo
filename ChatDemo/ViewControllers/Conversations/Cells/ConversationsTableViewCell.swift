//
//  ConversationsTableViewCell.swift
//  ChatDemo
//
//  Created by Duc Canh on 03/05/2023.
//

import UIKit
import RxSwift

class ConversationsTableViewCell: UITableViewCell {

    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var nameConversationLabel: UILabel!

    private let storageManager = StorageManager()
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(model: Conversation) {
        nameConversationLabel.text = model.name
        messageLabel.text = model.latestMessage.text
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        let imageUrlString: Observable<String> =  storageManager.downloadURL(for: path)
            .mapGetResultValue()

        imageUrlString.asDriverOnErrorJustComplete()
            .drive { [weak self] imageUrlString in
                guard let imageUrl = URL(string: imageUrlString) else {
                    return
                }
                self?.userImageView.setImage(with: imageUrl)
            }
            .disposed(by: disposeBag)
    }
    
}
