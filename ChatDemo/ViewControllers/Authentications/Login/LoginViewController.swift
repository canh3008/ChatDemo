//
//  LoginViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

class LoginViewController: BaseViewController {

    @IBOutlet private weak var emailView: DCTextField!
    @IBOutlet private weak var passwordView: DCTextField!
    @IBOutlet private weak var logInButton: DCButton!

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func setupUI() {
        super.setupUI()
        title = "Log In"
        addRegisterButton()
    }

    override func bindingData() {
        super.bindingData()
        let input = LoginViewModel.Input(email: emailView.rx.text,
                                         password: passwordView.rx.text,
                                         tapLogin: logInButton.rx.tap)
        let output = viewModel.transform(input: input)

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
            .isPasswordSuccess
            .skip(1)
            .map({ !$0 })
            .drive(passwordView.rx.isError)
            .disposed(by: disposeBag)

        output
            .isEnableLogin
            .drive(logInButton.rx.isEnable)
            .disposed(by: disposeBag)

    }

    override func bindingAction() {
        super.bindingAction()
        emailView
            .textFieldShouldReturnSubject
            .mapToVoid()
            .bind(to: passwordView.rx.becomeFirstResponse)
            .disposed(by: disposeBag)
    }

    private func addRegisterButton() {
        navigationItem.rightBarButtonItem = BarButtonItem(title: "Register",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(didTapRegister))
    }
}

extension LoginViewController {
    @objc func didTapRegister() {
        let registerViewController = RegisterViewController(viewModel: RegisterViewModel())
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
}
