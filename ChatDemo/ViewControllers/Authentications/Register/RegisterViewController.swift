//
//  RegisterViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

class RegisterViewController: BaseViewController {

    @IBOutlet private weak var lastNameView: DCTextField!
    @IBOutlet private weak var firstNameView: DCTextField!
    @IBOutlet private weak var emailView: DCTextField!
    @IBOutlet private weak var passwordView: DCTextField!
    @IBOutlet private weak var registerButton: DCButton!

    private let viewModel: RegisterViewModel

    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        title = "Create Account"
    }

    override func bindingData() {
        super.bindingData()
        let input = RegisterViewModel.Input(firstName: firstNameView.rx.text,
                                            lastName: lastNameView.rx.text,
                                            email: emailView.rx.text,
                                            password: passwordView.rx.text,
                                            tapRegister: registerButton.rx.tap)
        let output = viewModel.transform(input: input)

        output
            .firstNameError
            .drive(firstNameView.rx.messageError)
            .disposed(by: disposeBag)

        output
            .isFirstNameSuccess
            .skip(1)
            .map({ !$0 })
            .drive(firstNameView.rx.isError)
            .disposed(by: disposeBag)

        output
            .lastNameError
            .drive(lastNameView.rx.messageError)
            .disposed(by: disposeBag)

        output
            .isLastNameSuccess
            .skip(1)
            .map({ !$0 })
            .drive(lastNameView.rx.isError)
            .disposed(by: disposeBag)

        output
            .emailError
            .drive(emailView.rx.messageError)
            .disposed(by: disposeBag)

        output
            .isEmailSuccess
            .skip(1)
            .map({ !$0 })
            .drive(emailView.rx.isError)
            .disposed(by: disposeBag)

        output
            .passwordError
            .drive(passwordView.rx.messageError)
            .disposed(by: disposeBag)

        output
            .isPasswordError
            .skip(1)
            .map({ !$0 })
            .drive(passwordView.rx.isError)
            .disposed(by: disposeBag)

        output
            .isEnableRegister
            .drive(registerButton.rx.isEnable)
            .disposed(by: disposeBag)

    }

    override func bindingAction() {
        super.bindingAction()
        firstNameView
            .textFieldShouldReturnSubject
            .mapToVoid()
            .bind(to: lastNameView.rx.becomeFirstResponse)
            .disposed(by: disposeBag)

        lastNameView
            .textFieldShouldReturnSubject
            .mapToVoid()
            .bind(to: emailView.rx.becomeFirstResponse)
            .disposed(by: disposeBag)

        emailView
            .textFieldShouldReturnSubject
            .mapToVoid()
            .bind(to: passwordView.rx.becomeFirstResponse)
            .disposed(by: disposeBag)
    }

}
