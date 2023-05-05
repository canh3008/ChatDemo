//
//  ProfileHeaderView.swift
//  ChatDemo
//
//  Created by Duc Canh on 04/05/2023.
//

import UIKit

class ProfileHeaderView: BaseView {

    @IBOutlet fileprivate weak var profileImageView: UIImageView!
    
    override func initView() {
        Bundle.main.loadNibNamed(className, owner: self)
        self.addSubview(contentView)
        super.initView()
    }

    func setupUI(with imageUrl: URL) {
        self.profileImageView.setImage(with: imageUrl)
    }
}
