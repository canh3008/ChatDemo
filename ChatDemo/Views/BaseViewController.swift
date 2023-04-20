//
//  BaseViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingData()
    }

    func setupUI() {

    }

    func bindingData() {

    }

    deinit {
        print(String(describing: Self.self), "deinit")
    }
}
