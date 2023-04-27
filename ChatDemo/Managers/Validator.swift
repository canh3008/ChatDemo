//
//  Validator.swift
//  ChatDemo
//
//  Created by Duc Canh on 18/04/2023.
//

import Foundation
import RxSwift

enum ValidationResult<Failed> {
    case success
    case failed(Failed)
}

protocol ValidateFeature {
    associatedtype ResultValue
    associatedtype Value
    func checkValidate(with type: ValidationType<Value>) -> Observable<ValidationResult<ResultValue>>
}

enum ValidationType<Value> {
    case email(Value)
    case password(Value)
    case name(Value)
}

enum MessageErrorDefault: String {
    case notDefined = "Not defined object"
    case email = "Email error"
    case emailEmpty = "Please enter the email"
    case password = "Password error"
    case passwordEmpty = "Please enter the password"
    case firstName = "First name error"
    case firstNameEmpty = "Please enter the first name"
    case lastName = "Last name error"
    case lastNameEmpty = "Please enter the last name"
}

class Validator: ValidateFeature {
    typealias ResultValue = String
    func checkValidate(with type: ValidationType<String>) -> Observable<ValidationResult<ResultValue>> {
        Observable.create { [weak self] observer -> Disposable in
            switch type {
            case .email(let email):
                observer.onNext(self?.getEmailValidationResult(email) ?? .failed(MessageErrorDefault.notDefined.rawValue))
            case .password(let password):
                observer.onNext(self?.getPasswordValidationResult(password) ?? .failed(MessageErrorDefault.notDefined.rawValue))
            case .name(let name):
                observer.onNext(self?.getNameValidationResult(name) ?? .failed(MessageErrorDefault.notDefined.rawValue))
            }
            return Disposables.create()
        }
    }

    private func getEmailValidationResult(_ email: String) -> ValidationResult<ResultValue> {
        guard !email.isEmpty else {
            return .failed(MessageErrorDefault.emailEmpty.rawValue)
        }
        return email.isValidEmail ? .success : .failed(MessageErrorDefault.email.rawValue)
    }

    private func getPasswordValidationResult(_ password: String) -> ValidationResult<ResultValue> {
        guard !password.isEmpty else {
            return .failed(MessageErrorDefault.passwordEmpty.rawValue)
        }
        return password.isValidatePassword() ? .success : .failed(MessageErrorDefault.email.rawValue)

    }

    private func getNameValidationResult(_ name: String) -> ValidationResult<ResultValue> {
        guard !name.isEmpty else {
            return .failed(MessageErrorDefault.firstNameEmpty.rawValue)
        }
        return name.isValidateName() ? .success : .failed(MessageErrorDefault.firstName.rawValue)
    }
}
