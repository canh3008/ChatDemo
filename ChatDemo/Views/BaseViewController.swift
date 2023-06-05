//
//  BaseViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import RxSwift

protocol FeatureCommonBase {
    func setupUI()
}

protocol BindingBase {
    func bindingData()
    func bindingAction()
}

class SpecialBaseViewController: UIViewController, FeatureCommonBase {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {

    }

    deinit {
        print(String(describing: Self.self), "deinit")
    }

}

class BaseViewController: UIViewController, FeatureCommonBase, BindingBase {

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingData()
        bindingAction()

        print("Init:", String(describing: Self.self))
    }

    func setupUI() {

    }

    func bindingData() {

    }

    func bindingAction() {

    }

    deinit {
        print(String(describing: Self.self), "deinit")
    }
}
