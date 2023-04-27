//
//  RegisterViewModel.swift
//  ChatDemo
//
//  Created by Duc Canh on 22/04/2023.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel: BaseViewModel, ViewModelTransformable {
    private let validator: Validator

    init(validator: Validator = Validator()) {
        self.validator = validator
    }

    func transform(input: Input) -> Output {
        
        let validateEmail = input.email
            .flatMapLatest { [weak self] email -> Observable<ValidationResult<Validator.ResultValue>> in
                guard let self = self else {
                    return .empty()
                }
                return self.validator.checkValidate(with: .email(email))
            }

        let validateEmailError = validateEmail
            .mapValidationError()
            .asDriverOnErrorJustComplete()

        let isValidateEmailSuccess = validateEmail
            .mapValidationSuccess()
            .asDriverOnErrorJustComplete()

        let validatePassword = input.password
            .flatMapLatest { [weak self] password -> Observable<ValidationResult<Validator.ResultValue>> in
                guard let self = self else {
                    return .empty()
                }
                return self.validator.checkValidate(with: .password(password))
            }

        let validatePasswordError = validatePassword
            .mapValidationError()
            .asDriverOnErrorJustComplete()

        let isValidatePasswordSuccess = validatePassword
            .mapValidationSuccess()
            .asDriverOnErrorJustComplete()

        let validateFirstName = input.firstName
            .flatMapLatest { [weak self] name -> Observable<ValidationResult<Validator.ResultValue>> in
                guard let self = self else {
                    return .empty()
                }
                return self.validator.checkValidate(with: .name(name))
            }

        let validateFirstNameError = validateFirstName
            .mapValidationError()
            .asDriverOnErrorJustComplete()

        let isValidateFirstNameSuccess = validateFirstName
            .mapValidationSuccess()
            .asDriverOnErrorJustComplete()

        let validateLastName = input.lastName
            .flatMapLatest { [weak self] name -> Observable<ValidationResult<Validator.ResultValue>> in
                guard let self = self else {
                    return .empty()
                }
                return self.validator.checkValidate(with: .name(name))
            }

        let validateLastNameError = validateLastName
            .mapValidationError()
            .asDriverOnErrorJustComplete()

        let isValidateLastNameSuccess = validateLastName
            .mapValidationSuccess()
            .asDriverOnErrorJustComplete()

        let commonValidateSuccess = Driver.combineLatest(isValidatePasswordSuccess,
                                                         isValidateEmailSuccess,
                                                         isValidateFirstNameSuccess,
                                                         isValidateLastNameSuccess)
            .map({ $0 && $1 && $2 && $3})
        return Output(emailError: validateEmailError,
                      isEmailSuccess: isValidateEmailSuccess,
                      passwordError: validatePasswordError,
                      isPasswordError: isValidatePasswordSuccess,
                      firstNameError: validateFirstNameError,
                      isFirstNameSuccess: isValidateFirstNameSuccess,
                      lastNameError: validateLastNameError,
                      isLastNameSuccess: isValidateLastNameSuccess,
                      isEnableRegister: commonValidateSuccess)
    }
}

extension RegisterViewModel {
    struct Input {
        let firstName: Observable<String>
        let lastName: Observable<String>
        let email: Observable<String>
        let password: Observable<String>
        let tapRegister: Observable<Void>
    }

    struct Output {
        let emailError: Driver<String>
        let isEmailSuccess: Driver<Bool>
        let passwordError: Driver<String>
        let isPasswordError: Driver<Bool>
        let firstNameError: Driver<String>
        let isFirstNameSuccess: Driver<Bool>
        let lastNameError: Driver<String>
        let isLastNameSuccess: Driver<Bool>
        let isEnableRegister: Driver<Bool>
    }
}
