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
}

enum MessageErrorDefault: String {
    case notDefined = "Not defined object"
    case email = "Email Error"
    case emailEmpty = "Please enter the email"
    case password = "Password Error"
    case passwordEmpty = "Please enter the password"
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
            }
            return Disposables.create()
        }
    }

    func getEmailValidationResult(_ email: String) -> ValidationResult<ResultValue> {
        guard !email.isEmpty else {
            return .failed(MessageErrorDefault.emailEmpty.rawValue)
        }
        return email.isValidEmail ? .success : .failed(MessageErrorDefault.email.rawValue)
    }

    func getPasswordValidationResult(_ password: String) ->  ValidationResult<ResultValue> {
        guard !password.isEmpty else {
            return .failed(MessageErrorDefault.passwordEmpty.rawValue)
        }
        return password.isValidatePassword() ? .success : .failed(MessageErrorDefault.email.rawValue)

    }
}
