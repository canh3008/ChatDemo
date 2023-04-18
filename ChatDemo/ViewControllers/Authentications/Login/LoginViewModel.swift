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

        
        return Output()
    }
}

extension LoginViewModel {
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let tapLogin: Observable<Void>
    }

    struct Output {

    }
}
