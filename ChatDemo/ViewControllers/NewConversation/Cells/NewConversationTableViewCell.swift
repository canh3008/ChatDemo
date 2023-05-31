//
//  NewConversationTableViewCell.swift
//  ChatDemo
//
//  Created by Duc Canh on 05/05/2023.
//

import UIKit

class NewConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(with name: String) {
        nameLabel.text = name
    }
    
}
