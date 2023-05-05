//
//  UIImageView+Extension.swift
//  ChatDemo
//
//  Created by Duc Canh on 05/05/2023.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with url: URL) {
        self.kf.setImage(with: url)
    }
}
