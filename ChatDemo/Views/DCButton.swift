//
//  DCButton.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import RxSwift
import RxCocoa

class DCButton: BaseView {
    
    @IBOutlet fileprivate weak var baseButton: UIButton!

    @IBInspectable var backgroundButton: UIColor = .white {
        didSet {
            baseButton.backgroundColor = backgroundButton
        }
    }

    @IBInspectable var title: String = "" {
        didSet {
            baseButton.setTitle(title, for: .normal)
        }
    }

    @IBInspectable var textColor: UIColor = .black {
        didSet {
            baseButton.tintColor = textColor
        }
    }

    @IBInspectable var cornerRadiusButton: CGFloat = 0 {
        didSet {
            baseButton.layer.cornerRadius = cornerRadiusButton
        }
    }

    override func initView() {
        Bundle.main.loadNibNamed(className, owner: self)
        self.addSubview(contentView)
        super.initView()
        setupUI()
    }
}

extension DCButton {
    private func setupUI() {
        baseButton.backgroundColor = backgroundButton
        baseButton.tintColor = textColor
        baseButton.setTitle(title, for: .normal)
    }
}

extension Reactive where Base: DCButton {
    var isEnable: Binder<Bool> {
        return Binder(base) { dcButton, isEnable in
            dcButton.baseButton.isUserInteractionEnabled = isEnable
            dcButton.baseButton.backgroundColor = isEnable
            ? dcButton.backgroundButton
            : Theme.disable.color
        }
    }

    var tap: Observable<Void> {
        return base.baseButton.rx.tap.asObservable()
    }
}
