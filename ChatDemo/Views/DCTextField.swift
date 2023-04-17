//
//  DCTextField.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

class DCTextField: BaseView {

    @IBOutlet private weak var containerTextFieldView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var heightTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textField: BaseTextField!

    @IBInspectable var heightView: CGFloat = DefaultValue.heightTextFiled {
        didSet {
            heightTextFieldConstraint.constant = heightView
        }
    }

    @IBInspectable var isError: Bool = false {
        didSet {
            errorLabel.isHidden = !isError
        }
    }

    @IBInspectable var placeHolderText: String = "" {
        didSet {
            textField.placeholder = placeHolderText
        }
    }

    @IBInspectable var borderColerTextField: UIColor = .gray {
        didSet {
            containerTextFieldView.layer.borderColor = borderColerTextField.cgColor
        }
    }

    @IBInspectable var borderWidthTextField: CGFloat = 1.0 {
        didSet {
            containerTextFieldView.layer.borderWidth = borderWidthTextField
        }
    }

    @IBInspectable var cornerRadiusTextField: CGFloat = DefaultValue.heightTextFiled / 2 {
        didSet {
            containerTextFieldView.layer.cornerRadius = cornerRadiusTextField
        }
    }

    override func initView() {
        Bundle.main.loadNibNamed(className, owner: self)
        self.addSubview(contentView)
        super.initView()
        setupUI()
    }
}

extension DCTextField {
    private func setupUI() {
        errorLabel.isHidden = !isError

        containerTextFieldView.layer.borderWidth = borderWidthTextField
        containerTextFieldView.layer.borderColor = borderColerTextField.cgColor
        containerTextFieldView.layer.cornerRadius = cornerRadiusTextField
    }

    struct DefaultValue {
        static var heightTextFiled: CGFloat = 60
    }
}
