//
//  CommonTabBarViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

enum TabBarItem: CaseIterable {
    case chats
    case profile

    var title: String {
        switch self {
        case .chats:
            return "Chats"
        case .profile:
            return "Profile"
        }
    }

    var navigationController: UINavigationController {
        switch self {
        case .chats:
            let controller = ConversationsViewController()
            let navigation = UINavigationController(rootViewController: controller)
            navigation.tabBarItem.title = title
            return navigation
        case .profile:
            let controller = ProfileViewController(viewModel: ProfileViewModel())
            let navigation = UINavigationController(rootViewController: controller)
            navigation.tabBarItem.title = title
            return navigation
        }
    }
}

class CommonTabBarViewController: TabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTabBar()

    }

    func loadTabBar() {
        viewControllers = TabBarItem.allCases.map({ $0.navigationController })
        tabBar.tintColor = Theme.primaryTintColor.color
        tabBar.unselectedItemTintColor = Theme.secondTintColor.color
    }
}
