//
//  BaseAlert.swift
//  ChatDemo
//
//  Created by Duc Canh on 05/06/2023.
//

import UIKit

protocol AlertFeature {
    func showAlert(animated: Bool)
}

protocol PhotoAlertFeature {
    func showPhotoAlert(animated: Bool)
}

class BaseAlertViewController: NSObject, AlertFeature {
    var title: String?
    var message: String?
    var style: UIAlertController.Style

    init(title: String? = nil,
         message: String? = nil,
         style: UIAlertController.Style) {
        self.title = title
        self.message = message
        self.style = style
    }

    func showAlert(animated: Bool) {
    }
}
