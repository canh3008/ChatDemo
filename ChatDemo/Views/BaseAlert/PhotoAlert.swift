//
//  PhotoAlert.swift
//  ChatDemo
//
//  Created by Duc Canh on 06/06/2023.
//

import UIKit
import PhotosUI

protocol PhotoAlertViewControllerDelegate: AnyObject {
    func didSelectedPhotos(view: PhotoAlertViewController, photos: [UIImage])
}

class PhotoAlertViewController: BaseAlertViewController {

    private let selectionLimit: Int

    weak var delegate: PhotoAlertViewControllerDelegate?

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
        let camera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            alertViewController.dismiss(animated: animated) {
                self?.presentCamera()
            }
        }

        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            guard let self = self else {
                return
            }
            alertViewController.dismiss(animated: animated) {

                self.presentPhotoPicker(selectionLimit: self.selectionLimit)
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertViewController.dismiss(animated: false)
        }

        alertViewController.addAction(camera)
        alertViewController.addAction(photoLibrary)
        alertViewController.addAction(cancel)

        topViewController.present(alertViewController, animated: animated)
    }

    private func presentCamera() {
        guard let topViewController = UIApplication.topViewController() else {
            return
        }
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .camera
        pickerController.delegate = self
        pickerController.allowsEditing = true
        topViewController.present(pickerController, animated: true)
    }

    private func presentPhotoPicker(selectionLimit: Int) {
        guard let topViewController = UIApplication.topViewController() else {
            return
        }
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selection = .default
        config.selectionLimit = selectionLimit

        let pickerController = PHPickerViewController(configuration: config)
        pickerController.delegate = self
        topViewController.present(pickerController, animated: false)
    }
}

extension PhotoAlertViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false)
    }
}

extension PhotoAlertViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var photoSelected: [UIImage] = []
        let group = DispatchGroup()
        results
            .map({ $0.itemProvider })
            .forEach { itemProvider in
                group.enter()
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    guard error == nil, let image = object as? UIImage else {
                        print("zzzzzzzzzz error when get the selected photos")
                        return
                    }
                    photoSelected.append(image)
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            self.delegate?.didSelectedPhotos(view: self, photos: photoSelected)
            picker.dismiss(animated: false)
        }
    }
}
