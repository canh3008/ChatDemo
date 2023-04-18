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

    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let tapLogin: Observable<Void>
    }

    struct Output {

    }

    func transform(input: Input) -> Output {
        return Output()
    }
}
