//
//  LoginViewModel.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import Foundation
import RxCocoa
import RxSwift

class LoginViewModel: BaseViewModel, ViewModelTransformable {

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

        let commonValidateSuccess = Driver.combineLatest(isValidatePasswordSuccess, isValidateEmailSuccess)
            .map({ $0 && $1 })

        return Output(emailError: validateEmailError,
                      isEmailSuccess: isValidateEmailSuccess,
                      passwordError: validatePasswordError,
                      isPasswordError: isValidatePasswordSuccess,
                      isEnableLogin: commonValidateSuccess)
    }
}

extension LoginViewModel {
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let tapLogin: Observable<Void>
    }

    struct Output {
        let emailError: Driver<String>
        let isEmailSuccess: Driver<Bool>
        let passwordError: Driver<String>
        let isPasswordError: Driver<Bool>
        let isEnableLogin: Driver<Bool>
    }
}
