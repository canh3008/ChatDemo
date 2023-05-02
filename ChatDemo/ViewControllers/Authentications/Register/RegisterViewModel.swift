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

        let validateFirstName = input.firstName
            .flatMapLatest { [weak self] name -> Observable<Result<Validator.ResultValue>> in
                guard let self = self else {
                    return .empty()
                }
                return self.validator.checkValidate(with: .name(name))
            }

        let validateFirstNameError = validateFirstName
            .mapGetMessageError()
            .asDriverOnErrorJustComplete()

        let isValidateFirstNameSuccess = validateFirstName
            .mapGetResultSuccess()
            .asDriverOnErrorJustComplete()

        let validateLastName = input.lastName
            .flatMapLatest { [weak self] name -> Observable<Result<Validator.ResultValue>> in
                guard let self = self else {
                    return .empty()
                }
                return self.validator.checkValidate(with: .name(name))
            }

        let validateLastNameError = validateLastName
            .mapGetMessageError()
            .asDriverOnErrorJustComplete()

        let isValidateLastNameSuccess = validateLastName
            .mapGetResultSuccess()
            .asDriverOnErrorJustComplete()

        let commonValidateSuccess = Driver.combineLatest(isValidatePasswordSuccess,
                                                         isValidateEmailSuccess,
                                                         isValidateFirstNameSuccess,
                                                         isValidateLastNameSuccess)
            .map({ $0 && $1 && $2 && $3})

        let infos = Observable
            .combineLatest(input.email, input.password)
            .map({ (email: $0, password: $1) })

        let requestRegisterEmail = input
            .tapRegister
            .withLatestFrom(infos)
            .flatMapLatest { [weak self] info -> Observable<Result<FirebaseAuthentication.ErrorType>> in
                guard let self = self else {
                    return .empty()
                }
                return self.authentication.createAccountWithEmail(with: info)
            }
            .share()

        let registerEmailFail = requestRegisterEmail
            .mapGetMessageError()
            .asDriverOnErrorJustComplete()

        let registerEmailSuccess = requestRegisterEmail
            .mapGetResultSuccess()
            .filter({ $0 })

        let chatAppUser = Observable
            .combineLatest(input.firstName,
                           input.lastName,
                           input.email)
            .map({ ChatAppUser(firstName: $0,
                               lastName: $1,
                               emailAddress: $2,
                               token: nil)})
        registerEmailSuccess
            .withLatestFrom(chatAppUser)
            .subscribe { [weak self] chatAppUser in
                self?.insertInfoToDatabase(user: chatAppUser)
            }
            .disposed(by: disposeBag)

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
                      isPasswordError: isValidatePasswordSuccess,
                      firstNameError: validateFirstNameError,
                      isFirstNameSuccess: isValidateFirstNameSuccess,
                      lastNameError: validateLastNameError,
                      isLastNameSuccess: isValidateLastNameSuccess,
                      isEnableRegister: commonValidateSuccess,
                      isShowPassword: isShowPassword,
                      registerError: registerEmailFail,
                      registerSuccess: registerEmailSuccess.asDriverOnErrorJustComplete())
    }

    private func insertInfoToDatabase(user: ChatAppUser) {
        DatabaseManager.shared.insertUser(with: user)
    }
}

extension RegisterViewModel {
    struct Input {
        let firstName: Observable<String>
        let lastName: Observable<String>
        let email: Observable<String>
        let password: Observable<String>
        let tapRegister: Observable<Void>
        let tapShowPassword: Observable<Void>
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
        let isShowPassword: Driver<Bool>
        let registerError: Driver<String>
        let registerSuccess: Driver<Bool>
    }
}
