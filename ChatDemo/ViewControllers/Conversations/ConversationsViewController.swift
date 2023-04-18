//
//  ConversationsViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthentication()
    }

    private func checkAuthentication() {
        let isLoggedIn = UserDefaultManager<Bool>().getData(key: .isLoggedIn) ?? false
        if !isLoggedIn {
            let viewController = LoginViewController(viewModel: LoginViewModel())
            let navigation = NavigationController(rootViewController: viewController)
            navigation.modalPresentationStyle = .fullScreen
            self.present(navigation, animated: true)
        }
    }
}
