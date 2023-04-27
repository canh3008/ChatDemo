//
//  DCTextField.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import RxSwift

class DCTextField: BaseView {

    @IBOutlet private weak var containerTextFieldView: UIView!
    @IBOutlet fileprivate weak var errorLabel: UILabel!
    @IBOutlet private weak var heightTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var textField: BaseTextField!
    @IBOutlet fileprivate weak var showButton: UIButton!

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

    @IBInspectable var isShowEyeButton: Bool = false {
        didSet {
            showButton.isHidden = !isShowEyeButton
        }
    }

    // Public Properties
    var textFieldShouldReturnSubject = PublishSubject<UIView>()

    override func initView() {
        Bundle.main.loadNibNamed(className, owner: self)
        self.addSubview(contentView)
        super.initView()
        setupUI()
        addDelegate()
    }
}

extension DCTextField {
    private func setupUI() {
        errorLabel.isHidden = !isError
        showButton.isHidden = !isShowEyeButton
        updateUI(isShow: false)

        containerTextFieldView.layer.borderWidth = borderWidthTextField
        containerTextFieldView.layer.borderColor = borderColerTextField.cgColor
        containerTextFieldView.layer.cornerRadius = cornerRadiusTextField
    }

    private func addDelegate() {
        textField.delegate = self
    }

    private func setImageForShowButton(isShow: Bool) {
        let nameImage = isShow ? "hide_password_ic" : "show_password_ic"
        showButton.setImage(UIImage(named: nameImage),
                                        for: .normal)
    }

    private func setSecureTextForTextField(isSecureText: Bool) {
        textField.isSecureTextEntry = isSecureText
    }

    fileprivate func updateUI(isShow: Bool) {
        setImageForShowButton(isShow: isShow)
        setSecureTextForTextField(isSecureText: !isShow)
    }

    struct DefaultValue {
        static var heightTextFiled: CGFloat = 50
    }
}

extension DCTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldShouldReturnSubject.onNext(self)
        return true
    }
}

extension Reactive where Base: DCTextField {
    var text: Observable<String> {
        return base.textField.rx.value.compactMap({ $0 })
    }

    var messageError: Binder<String> {
        return Binder(base) { dcTextField, messageError in
            dcTextField.errorLabel.text = messageError
        }
    }

    var isError: Binder<Bool> {
        return Binder(base) { dcTextField, isError in
            dcTextField.errorLabel.isHidden = !isError
            if isError {
                dcTextField.errorLabel.textColor = Theme.error.color
            }
        }
    }

    var becomeFirstResponse: Binder<Void> {
        return Binder(base) { dcTextField, _ in
            dcTextField.textField.becomeFirstResponder()
        }
    }

    var tapShowInfo: Observable<Void> {
        return base.showButton.rx.tap.asObservable()
    }

    var isShowInfo: Binder<Bool> {
        return Binder(base) { dcTextField, isShow in
            dcTextField.updateUI(isShow: isShow)
        }
    }

}
