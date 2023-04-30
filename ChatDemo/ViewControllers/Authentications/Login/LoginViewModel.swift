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
    private let authentication: FirebaseAuthentication

    private var isShowPasswordSubject = BehaviorRelay<Bool>(value: true)

    init(validator: Validator = Validator(),
         authentication: FirebaseAuthentication = FirebaseAuthentication()) {
        self.validator = validator
        self.authentication = authentication
    }

    func transform(input: Input) -> Output {

        let validateEmail = input.email
            .flatMapLatest { [weak self] email -> Observable<Result<Validator.ResultValue>> in
                guard let self = self else {
                    return .empty()
                }
                return self.validator.checkValidate(with: .email(email))
            }

        let validateEmailError = validateEmail
            .mapGetMessageError()
            .asDriverOnErrorJustComplete()

        let isValidateEmailSuccess = validateEmail
            .mapGetResultSuccess()
            .asDriverOnErrorJustComplete()

        let validatePassword = input.password
            .flatMapLatest { [weak self] password -> Observable<Result<Validator.ResultValue>> in
                guard let self = self else {
                    return .empty()
                }
                return self.validator.checkValidate(with: .password(password))
            }

        let validatePasswordError = validatePassword
            .mapGetMessageError()
            .asDriverOnErrorJustComplete()

        let isValidatePasswordSuccess = validatePassword
            .mapGetResultSuccess()
            .asDriverOnErrorJustComplete()

        let commonValidateSuccess = Driver.combineLatest(isValidatePasswordSuccess, isValidateEmailSuccess)
            .map({ $0 && $1 })

        let infos = Observable
            .combineLatest(input.email, input.password)
            .map({ (email: $0, password: $1) })

        let requestLoginEmail = input
            .tapLogin
            .withLatestFrom(infos)
            .flatMapLatest { [weak self] info -> Observable<Result<FirebaseAuthentication.ErrorType>> in
                guard let self = self else {
                    return .empty()
                }
                return self.authentication.logInWithEmail(with: info)
            }
            .share()

        let loginEmailFail = requestLoginEmail
            .mapGetMessageError()
            .asDriverOnErrorJustComplete()

        let loginEmailSuccess = requestLoginEmail
            .mapGetResultSuccess()
            .filter({ $0 })
            .asDriverOnErrorJustComplete()

        let isShowPassword = input
            .tapShowPassword
            .withLatestFrom(isShowPasswordSubject)
            .do(onNext: { [weak self] _ in
                let currentValue = self?.isShowPasswordSubject.value
                self?.isShowPasswordSubject.accept(!(currentValue ?? false))
            }).asDriverOnErrorJustComplete()

        return Output(emailError: validateEmailError,
                      isEmailSuccess: isValidateEmailSuccess,
                      passwordError: validatePasswordError,
                      isPasswordSuccess: isValidatePasswordSuccess,
                      isEnableLogin: commonValidateSuccess,
                      isShowPassword: isShowPassword,
                      loginSuccess: loginEmailSuccess,
                      loginError: loginEmailFail)
    }
}

extension LoginViewModel {
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let tapLogin: Observable<Void>
        let tapShowPassword: Observable<Void>
    }

    struct Output {
        let emailError: Driver<String>
        let isEmailSuccess: Driver<Bool>
        let passwordError: Driver<String>
        let isPasswordSuccess: Driver<Bool>
        let isEnableLogin: Driver<Bool>
        let isShowPassword: Driver<Bool>
        let loginSuccess: Driver<Bool>
        let loginError: Driver<String>
    }
}
