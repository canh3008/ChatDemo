//
//  BaseTextField.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

class BaseTextField: UITextField {

    @IBInspectable var leftSpacing: CGFloat = 5.0 {
        didSet {
            initView(with: leftSpacing)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView(with: leftSpacing)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView(with: leftSpacing)
    }

}

extension BaseTextField {
    private func initView(with leftSpacing: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: leftSpacing, height: 0))
        self.leftViewMode = .always
    }
}
