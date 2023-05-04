//
//  ConversationsTableViewCell.swift
//  ChatDemo
//
//  Created by Duc Canh on 03/05/2023.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameConversationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(model: String) {
        nameConversationLabel.text = model
    }
    
}
