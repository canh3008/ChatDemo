//
//  NavigationController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count >= 1 {
            let leftBarButton = BarButtonItem(image: UIImage(named: "lefterbackicon_titlebar_24x24_")?.withRenderingMode(.alwaysOriginal),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBackIcon))
            viewController.navigationItem.leftBarButtonItem = leftBarButton
        }
        super.pushViewController(viewController, animated: animated)
    }
}

extension NavigationController {
    @objc func didTapBackIcon() {
        self.popViewController(animated: true)
    }
}
