//
//  AuthenticationManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 28/04/2023.
//

import Foundation
import FirebaseAuth
import RxSwift

typealias InfoAccount = (email: String, password: String)

enum FirebaseAuthenticationErrorMessage: String {
    case createAccount = "Error creating user"
    case signIn = "Error Sign In"
}

protocol EmailAuthenticationFeature {
    associatedtype ErrorType
    var isCurrentUser: Bool { get }
    func logInWithEmail(with info: InfoAccount) -> Observable<Result<ErrorType>>
    func createAccountWithEmail(with info: InfoAccount) -> Observable<Result<ErrorType>>
}

class FirebaseAuthentication: EmailAuthenticationFeature {
    typealias ErrorType = String
    
    var isCurrentUser: Bool {
        print("zzzzzz", FirebaseAuth.Auth.auth().currentUser)
        return FirebaseAuth.Auth.auth().currentUser != nil
    }

    func logInWithEmail(with info: InfoAccount) -> Observable<Result<ErrorType>> {
        Observable.create { observer -> Disposable in
            FirebaseAuth
                .Auth
                .auth()
                .signIn(withEmail: info.email,
                        password: info.password) { _, error in
                    if let error = error {
                        let messageError = error.localizedDescription
                        observer.onNext(.failed(messageError))
                    } else {
                        observer.onNext(.success)
                    }
                }
            return Disposables.create()
        }
    }

    func createAccountWithEmail(with info: InfoAccount) -> Observable<Result<ErrorType>> {
        Observable.create { observer -> Disposable in
            FirebaseAuth
                .Auth
                .auth()
                .createUser(withEmail: info.email,
                            password: info.password) { _, error in
                    if let error = error {
                        let messageError = error.localizedDescription
                        observer.onNext(.failed(messageError))
                    } else {
                        observer.onNext(.success)
                    }
                }
            return Disposables.create()
        }
    }
}
