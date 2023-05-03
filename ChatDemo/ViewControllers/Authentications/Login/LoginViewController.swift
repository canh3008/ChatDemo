//
//  LoginViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import FBSDKLoginKit
import RxSwift

class LoginViewController: BaseViewController {

    @IBOutlet private weak var emailView: DCTextField!
    @IBOutlet private weak var passwordView: DCTextField!
    @IBOutlet private weak var logInButton: DCButton!
    @IBOutlet private weak var facebookView: UIView!
    
    private let viewModel: LoginViewModel
    private var infoFacebook = PublishSubject<ChatAppUser>()
    private var tapGoogleLogin = PublishSubject<Void>()

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
        addFacebookButton()
    }

    override func bindingData() {
        super.bindingData()
        let input = LoginViewModel.Input(email: emailView.rx.text,
                                         password: passwordView.rx.text,
                                         tapLogin: logInButton.rx.tap,
                                         tapShowPassword: passwordView.rx.tapShowInfo,
                                         tapLoginWithFacebook: infoFacebook,
                                         tapLoginWithGoogle: tapGoogleLogin)
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

        output
            .isShowPassword
            .drive(passwordView.rx.isShowInfo)
            .disposed(by: disposeBag)

        output
            .loginSuccess
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        output
            .loginError
            .drive(rx.showMessageError)
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

    private func addFacebookButton() {
        let loginButton = FBLoginButton()
        facebookView.addSubview(loginButton)
        loginButton.anchor(top: facebookView.topAnchor,
                           left: facebookView.leftAnchor,
                           bottom: facebookView.bottomAnchor,
                           right: facebookView.rightAnchor)
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]

    }

    @IBAction func signIn(sender: Any) {
        self.tapGoogleLogin.onNext(())
    }
}

extension LoginViewController {
    @objc func didTapRegister() {
        let registerViewController = RegisterViewController(viewModel: RegisterViewModel())
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            Observable
                .just(error?.localizedDescription)
                .compactMap({ $0 })
                .bind(to: rx.showMessageError)
                .disposed(by: disposeBag)
            return
        }
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"], tokenString: token, version: nil,
                                                         httpMethod: .get)
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Fail to make facebook graph request")
                return
            }

            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("Fail to get user name and email from fb request")
                return
            }
            let nameComponents = userName.components(separatedBy: " ")
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            self.infoFacebook.onNext(ChatAppUser(firstName: firstName,
                                                  lastName: lastName,
                                                  emailAddress: email,
                                                  token: token))
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        
    }
}
