//
//  LoadingService.swift
//  ChatDemo
//
//  Created by Duc Canh on 30/04/2023.
//

import UIKit

protocol LoadingFeature {
    func show()
    func hide()
}

class LoadingService: LoadingFeature {
    let activity = UIActivityIndicatorView(style: .medium)
    func show() {
        guard let window = UIApplication.shared.currentUIWindow() else {
            return
        }
        activity.backgroundColor = .gray
        activity.color = .white
        activity.cornerRadius = Dimension.radius
        activity.frame = CGRect(center: window.center, size: Dimension.size)
        window.addSubview(activity)
        DispatchQueue.main.async {
            self.activity.startAnimating()
        }

    }

    func hide() {
        activity.stopAnimating()
    }
}

extension LoadingService {
    struct Dimension {
        static let width: CGFloat = 80
        static let height: CGFloat = 80

        static var radius: CGFloat {
            return width * 0.2
        }

        static var size: CGSize {
            return CGSize(width: width, height: height)
        }
    }
}
