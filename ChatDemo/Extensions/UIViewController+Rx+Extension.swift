//
//  UIViewController+Rx+Extension.swift
//  ChatDemo
//
//  Created by Duc Canh on 28/04/2023.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {

    var showMessageError: Binder<String> {
        return Binder(base) { controller, message in
            controller.showAlert(title: nil, message: message)
        }
    }
}
