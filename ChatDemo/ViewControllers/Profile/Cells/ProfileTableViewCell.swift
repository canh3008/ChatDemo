//
//  ProfileTableViewCell.swift
//  ChatDemo
//
//  Created by Duc Canh on 02/05/2023.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleProfileLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(with title: String) {
        titleProfileLabel.text = title
    }
}
