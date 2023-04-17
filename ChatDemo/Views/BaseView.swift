//
//  BaseView.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import SwifterSwift

class BaseView: UIView {

    @IBOutlet weak var contentView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    func initView() {
        contentView.anchor(top: self.topAnchor,
                           left: self.leftAnchor,
                           bottom: self.bottomAnchor,
                           right: self.rightAnchor)
    }
}
