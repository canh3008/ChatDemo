//
//  AuthenticationManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 28/04/2023.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import RxSwift
import FBSDKLoginKit
import GoogleSignIn

typealias InfoAccount = (email: String, password: String)

enum FirebaseAuthenticationErrorMessage: String {
    case createAccount = "Error creating user"
    case signIn = "Error Sign In"
}

protocol AuthenticationFeature {
    associatedtype ErrorType
}
protocol EmailAuthenticationFeature: AuthenticationFeature {
    var isCurrentUser: Bool { get }
    func logInWithEmail(with info: InfoAccount) -> Observable<Result<ErrorType>>
    func createAccountWithEmail(with info: InfoAccount) -> Observable<Result<ErrorType>>
    func logOutEmail() -> Observable<Result<ErrorType>>
}

protocol FacebookAuthenticationFeature: AuthenticationFeature {
    func logInWithFacebook(token: String) -> Observable<Result<ErrorType>>
    func logOutFacebook() -> Observable<Result<ErrorType>>
}

protocol GoogleAuthenticationFeature: AuthenticationFeature {
    func logInWithGoogle() -> Observable<Result<ErrorType>>
    func logOutGoogle() -> Observable<Result<ErrorType>>
}

class FirebaseAuthentication {
    typealias ErrorType = String

    private let loadingService: LoadingFeature

    init(loadingService: LoadingFeature = LoadingService()) {
        self.loadingService = loadingService
    }
    
    var isCurrentUser: Bool {
        return FirebaseAuth.Auth.auth().currentUser != nil
    }
}

extension FirebaseAuthentication: EmailAuthenticationFeature {
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

    func logOutEmail() -> Observable<Result<ErrorType>> {
        Observable.create { observer -> Disposable in
            do {
                try FirebaseAuth
                    .Auth
                    .auth()
                    .signOut()
                observer.onNext(.success)
            } catch let error {
                observer.onNext(.failed(error.localizedDescription))
            }
            return Disposables.create()
        }
    }
}

extension FirebaseAuthentication: FacebookAuthenticationFeature {
    func logInWithFacebook(token: String) -> Observable<Result<ErrorType>> {
        loadingService.show()
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        return Observable.create { observer -> Disposable in
            FirebaseAuth
                .Auth
                .auth()
                .signIn(with: credential) { [weak self] _, error in
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

    func logOutFacebook() -> Observable<Result<ErrorType>> {
        return Observable.create { observer -> Disposable in
            FBSDKLoginKit.LoginManager().logOut()
            observer.onNext(.success)
            return Disposables.create()
        }
    }
}

extension FirebaseAuthentication: GoogleAuthenticationFeature {
    func logInWithGoogle() -> Observable<Result<String>> {

        guard let clientID = FirebaseApp.app()?.options.clientID,
              let topViewController = UIApplication.topViewController() else {
            return .empty()
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        return Observable.create { observer -> Disposable in
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: topViewController) { signInResult, error in
                guard error == nil else {
                    observer.onNext(.failed(error?.localizedDescription ?? "Nil"))
                    self.loadingService.hide()
                    return
                }
                guard let user = signInResult?.user,
                      let idToken = user.idToken?.tokenString
                else {
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                self.loadingService.show()
                Auth.auth().signIn(with: credential) { result, error in
                    guard error == nil else {
                        observer.onNext(.failed(error?.localizedDescription ?? "Nil"))
                        self.loadingService.hide()
                        return
                    }
                    guard let user = result?.user,
                          let email = user.email,
                          let name = user.displayName else {
                        observer.onNext(.failed("Not get user from google account"))
                        self.loadingService.hide()
                        return
                    }
                    let nameComponents = name.components(separatedBy: " ")
                    guard nameComponents.count > 1 else {
                        observer.onNext(.failed("Not get user from google account"))
                        self.loadingService.hide()
                        return
                    }
                    let firstName = nameComponents[0]
                    let lastName = nameComponents[1]
                    let concurrentQueue = DispatchQueue(label: "Insert user", qos: .background)
                    concurrentQueue.async {
                        DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                            lastName: lastName,
                                                                            emailAddress: email,
                                                                            token: nil))
                    }
                    observer.onNext(.success)
                    self.loadingService.hide()
                }
            }
            return Disposables.create()
        }
    }

    func logOutGoogle() -> Observable<Result<ErrorType>> {
        return Observable.create { observer -> Disposable in
            GIDSignIn.sharedInstance.signOut()
            observer.onNext(.success)
            return Disposables.create()
        }
    }
}
