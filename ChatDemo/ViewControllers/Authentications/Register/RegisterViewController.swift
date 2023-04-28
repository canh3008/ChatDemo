//
//  RegisterViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import PhotosUI

class RegisterViewController: BaseViewController {

    @IBOutlet private weak var lastNameView: DCTextField!
    @IBOutlet private weak var firstNameView: DCTextField!
    @IBOutlet private weak var emailView: DCTextField!
    @IBOutlet private weak var passwordView: DCTextField!
    @IBOutlet private weak var registerButton: DCButton!
    @IBOutlet private weak var changePictureButton: UIButton!
    @IBOutlet private weak var personImageView: UIImageView!

    private let viewModel: RegisterViewModel

    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        title = "Create Account"
        setCornerRadiusPersionImage()
    }

    override func bindingData() {
        super.bindingData()
        let input = RegisterViewModel.Input(firstName: firstNameView.rx.text,
                                            lastName: lastNameView.rx.text,
                                            email: emailView.rx.text,
                                            password: passwordView.rx.text,
                                            tapRegister: registerButton.rx.tap,
                                            tapShowPassword: passwordView.rx.tapShowInfo)
        let output = viewModel.transform(input: input)

        output
            .firstNameError
            .drive(firstNameView.rx.messageError)
            .disposed(by: disposeBag)

        output
            .isFirstNameSuccess
            .skip(1)
            .map({ !$0 })
            .drive(firstNameView.rx.isError)
            .disposed(by: disposeBag)

        output
            .lastNameError
            .drive(lastNameView.rx.messageError)
            .disposed(by: disposeBag)

        output
            .isLastNameSuccess
            .skip(1)
            .map({ !$0 })
            .drive(lastNameView.rx.isError)
            .disposed(by: disposeBag)

        output
            .emailError
            .drive(emailView.rx.messageError)
            .disposed(by: disposeBag)

        output
            .isEmailSuccess
            .skip(1)
            .map({ !$0 })
            .drive(emailView.rx.isError)
            .disposed(by: disposeBag)

        output
            .passwordError
            .drive(passwordView.rx.messageError)
            .disposed(by: disposeBag)

        output
            .isPasswordError
            .skip(1)
            .map({ !$0 })
            .drive(passwordView.rx.isError)
            .disposed(by: disposeBag)

        output
            .isEnableRegister
            .drive(registerButton.rx.isEnable)
            .disposed(by: disposeBag)

        output
            .isShowPassword
            .drive(passwordView.rx.isShowInfo)
            .disposed(by: disposeBag)

    }

    override func bindingAction() {
        super.bindingAction()
        firstNameView
            .textFieldShouldReturnSubject
            .mapToVoid()
            .bind(to: lastNameView.rx.becomeFirstResponse)
            .disposed(by: disposeBag)

        lastNameView
            .textFieldShouldReturnSubject
            .mapToVoid()
            .bind(to: emailView.rx.becomeFirstResponse)
            .disposed(by: disposeBag)

        emailView
            .textFieldShouldReturnSubject
            .mapToVoid()
            .bind(to: passwordView.rx.becomeFirstResponse)
            .disposed(by: disposeBag)

        changePictureButton
            .rx
            .tap
            .bind { [weak self] _ in
                self?.presentPhotoActionSheet()
            }
            .disposed(by: disposeBag)
    }
}

extension RegisterViewController {
    private func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel))

        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))

        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }

    private func presentCamera() {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .camera
        pickerController.delegate = self
        pickerController.allowsEditing = true
        self.present(pickerController, animated: true)
    }

    private func getPhoto(from itemProvider: NSItemProvider, complete: @escaping () -> Void) {
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard error == nil else {
                    print("Selected image failed")
                    return
                }
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.personImageView.image = image
                        complete()
                    }
                }
            }
        }
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let pickerController = PHPickerViewController(configuration: config)
        pickerController.delegate = self
        self.present(pickerController, animated: true)
    }

    func setCornerRadiusPersionImage() {
        personImageView.layer.cornerRadius = UIScreen.main.bounds.width / 6
        personImageView.layer.borderWidth = 0.5
        personImageView.layer.borderColor = Theme.primaryBorder.color.cgColor
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}

extension RegisterViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
                return
        }
        getPhoto(from: results[0].itemProvider, complete: {
            picker.dismiss(animated: true)
        })
    }
}
