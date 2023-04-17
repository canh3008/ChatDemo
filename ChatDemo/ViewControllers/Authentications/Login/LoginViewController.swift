//
//  LoginViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

class LoginViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func setupUI() {
        super.setupUI()
        title = "Log In"
        addRegisterButton()
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
        let registerViewController = RegisterViewController()
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
}
