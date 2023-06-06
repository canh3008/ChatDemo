//
//  RegisterViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import PhotosUI
import RxSwift

class RegisterViewController: BaseViewController {

    @IBOutlet private weak var lastNameView: DCTextField!
    @IBOutlet private weak var firstNameView: DCTextField!
    @IBOutlet private weak var emailView: DCTextField!
    @IBOutlet private weak var passwordView: DCTextField!
    @IBOutlet private weak var registerButton: DCButton!
    @IBOutlet private weak var changePictureButton: UIButton!
    @IBOutlet private weak var personImageView: UIImageView!

    private let selectionLimit = 1
    private var photoAlertViewController: PhotoAlertViewController?
    private var picture = PublishSubject<UIImage?>()
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
                                            tapShowPassword: passwordView.rx.tapShowInfo,
                                            profilePicture: picture)
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

        output
            .registerSuccess
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        output
            .registerError
            .drive(rx.showMessageError)
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
        photoAlertViewController = PhotoAlertViewController(title: "Profile Picture",
                                                            message: "How would you like to select a picture?",
                                                            style: .actionSheet,
                                                            selectionLimit: selectionLimit)
        photoAlertViewController?.delegate = self
        photoAlertViewController?.showAlert(animated: false)
    }

    func setCornerRadiusPersionImage() {
        personImageView.layer.cornerRadius = UIScreen.main.bounds.width / 6
        personImageView.layer.borderWidth = 0.5
        personImageView.layer.borderColor = Theme.primaryBorder.color.cgColor
    }
}

extension RegisterViewController: PhotoAlertViewControllerDelegate {
    func didSelectedPhotos(view: PhotoAlertViewController, photos: [UIImage]) {
        guard photos.count == self.selectionLimit else {
            return
        }
        let image = photos[0]
        self.personImageView.image = image
        self.picture.onNext(image)
    }
}
