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
    func logOut() -> Observable<Result<ErrorType>>
}

class FirebaseAuthentication: EmailAuthenticationFeature {
    typealias ErrorType = String

    private let loadingService: LoadingFeature

    init(loadingService: LoadingFeature = LoadingService()) {
        self.loadingService = loadingService
    }
    
    var isCurrentUser: Bool {
        return FirebaseAuth.Auth.auth().currentUser != nil
    }

    func logInWithEmail(with info: InfoAccount) -> Observable<Result<ErrorType>> {
        loadingService.show()
        return Observable.create { observer -> Disposable in
            FirebaseAuth
                .Auth
                .auth()
                .signIn(withEmail: info.email,
                        password: info.password) { [weak self] _, error in
                    guard let self = self else {
                        return
                    }
                    if let error = error {
                        let messageError = error.localizedDescription
                        observer.onNext(.failed(messageError))
                    } else {
                        observer.onNext(.success)
                    }
                    self.loadingService.hide()
                }
            return Disposables.create()
        }
    }

    func createAccountWithEmail(with info: InfoAccount) -> Observable<Result<ErrorType>> {
        loadingService.show()
        return Observable.create { observer -> Disposable in
            FirebaseAuth
                .Auth
                .auth()
                .createUser(withEmail: info.email,
                            password: info.password) { [weak self] _, error in
                    guard let self = self else {
                        return
                    }
                    if let error = error {
                        let messageError = error.localizedDescription
                        observer.onNext(.failed(messageError))
                    } else {
                        observer.onNext(.success)
                    }
                    self.loadingService.hide()
                }
            return Disposables.create()
        }
    }

    func logOut() -> Observable<Result<ErrorType>> {
        Observable.create { observer -> Disposable in
            do {
                try FirebaseAuth
                    .Auth
                    .auth()
                    .signOut()
                observer.onNext(.success)
            }
            catch(let error) {
                observer.onNext(.failed(error.localizedDescription))
            }
            return Disposables.create()
        }
    }
}
