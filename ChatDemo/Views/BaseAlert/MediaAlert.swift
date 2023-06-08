//
//  MediaAlert.swift
//  ChatDemo
//
//  Created by Duc Canh on 06/06/2023.
//

import UIKit

protocol MediaAlertViewControllerDelegate: AnyObject {
    func didSelectedPhotos(view: MediaAlertViewController, photos: [UIImage])
}
class MediaAlertViewController: BaseAlertViewController, PhotoAlertFeature {

    private let selectionLimit: Int
    private var photoAlertViewController: PhotoAlertViewController?

    weak var delegate: MediaAlertViewControllerDelegate?

    init(title: String? = nil,
         message: String? = nil,
         style: UIAlertController.Style,
         selectionLimit: Int) {
        self.selectionLimit = selectionLimit
        super.init(title: title, message: message, style: style)
    }

    override func showAlert(animated: Bool) {
        guard let topViewController = UIApplication.topViewController() else {
            return
        }
        let alertViewController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: style)
        let photo = UIAlertAction(title: "Photo", style: .default) { [weak self] _ in
            alertViewController.dismiss(animated: animated) {
                self?.showPhotoAlert(animated: animated)
            }
        }

        let video = UIAlertAction(title: "Video", style: .default) { [weak self] _ in

        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            alertViewController.dismiss(animated: false)
        }

        alertViewController.addAction(photo)
        alertViewController.addAction(video)
        alertViewController.addAction(cancel)

        topViewController.present(alertViewController, animated: animated)
    }

    func showPhotoAlert(animated: Bool) {
        photoAlertViewController = PhotoAlertViewController(title: "Attach Photo",
                                                                message: "Where would you like to attach from?",
                                                                style: .actionSheet,
                                                                selectionLimit: selectionLimit)
        photoAlertViewController?.delegate = self
        photoAlertViewController?.showAlert(animated: animated)
    }
}

extension MediaAlertViewController: PhotoAlertViewControllerDelegate {
    func didSelectedPhotos(view: PhotoAlertViewController, photos: [UIImage]) {
        photoAlertViewController = nil
        delegate?.didSelectedPhotos(view: self, photos: photos)
    }
}
