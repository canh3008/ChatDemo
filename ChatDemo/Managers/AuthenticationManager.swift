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
import Kingfisher

typealias InfoAccount = (email: String, password: String)

enum FirebaseAuthenticationErrorMessage: String {
    case createAccount = "Error creating user"
    case signIn = "Error Sign In"
}

protocol AuthenticationFeature {
    associatedtype ErrorType
    associatedtype ValueReturn
}
protocol EmailAuthenticationFeature: AuthenticationFeature {
    var isCurrentUser: Bool { get }
    func logInWithEmail(with info: InfoAccount) -> Observable<Result<ValueReturn, ErrorType>>
    func createAccountWithEmail(with info: InfoAccount) -> Observable<Result<ValueReturn, ErrorType>>
    func logOutEmail() -> Observable<Result<ValueReturn, ErrorType>>
}

protocol FacebookAuthenticationFeature: AuthenticationFeature {
    func logInWithFacebook(token: String) -> Observable<Result<ValueReturn, ErrorType>>
    func logOutFacebook() -> Observable<Result<ValueReturn, ErrorType>>
}

protocol GoogleAuthenticationFeature: AuthenticationFeature {
    func logInWithGoogle() -> Observable<Result<ValueReturn, ErrorType>>
    func logOutGoogle() -> Observable<Result<ValueReturn, ErrorType>>
}

class FirebaseAuthentication {
    typealias ErrorType = String
    typealias ValueReturn = Void

    private let loadingService: LoadingFeature
    private let saveAccountManager: SaveAccountManager

    init(loadingService: LoadingFeature = LoadingService(),
         saveAccountManager: SaveAccountManager = SaveAccountManager()) {
        self.loadingService = loadingService
        self.saveAccountManager = saveAccountManager
    }
    
    var isCurrentUser: Bool {
        return FirebaseAuth.Auth.auth().currentUser != nil
    }
}

extension FirebaseAuthentication: EmailAuthenticationFeature {
    func logInWithEmail(with info: InfoAccount) -> Observable<Result<ValueReturn, ErrorType>> {
        loadingService.show()
        return Observable.create { observer -> Disposable in
            FirebaseAuth
                .Auth
                .auth()
                .signIn(withEmail: info.email,
                        password: info.password) { [weak self] result, error in
                    guard let self = self else {
                        return
                    }
                    let name = result?.user.displayName ?? ""
                    if let error = error {
                        let messageError = error.localizedDescription
                        observer.onNext(.failed(messageError))
                    } else {
                        self.saveAccountManager.setData(with: info.email, key: .email)
                        DatabaseManager.shared.getInfoCurrentUser { fullName in
                            self.saveAccountManager.setData(with: fullName, key: .fullName)
                        }
                        observer.onNext(.success(()))
                    }
                    self.loadingService.hide()
                }
            return Disposables.create()
        }
    }

    func createAccountWithEmail(with info: InfoAccount) -> Observable<Result<ValueReturn, ErrorType>> {
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
                        observer.onNext(.success(()))
                    }
                    self.loadingService.hide()
                }
            return Disposables.create()
        }
    }

    func logOutEmail() -> Observable<Result<ValueReturn, ErrorType>> {
        Observable.create { observer -> Disposable in
            do {
                try FirebaseAuth
                    .Auth
                    .auth()
                    .signOut()
                observer.onNext(.success(()))
            } catch let error {
                observer.onNext(.failed(error.localizedDescription))
            }
            return Disposables.create()
        }
    }
}

extension FirebaseAuthentication: FacebookAuthenticationFeature {
    func logInWithFacebook(token: String) -> Observable<Result<ValueReturn, ErrorType>> {
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
                        observer.onNext(.success(()))
                    }
                    self.loadingService.hide()
                }
            return Disposables.create()
        }
    }

    func logOutFacebook() -> Observable<Result<ValueReturn, ErrorType>> {
        return Observable.create { observer -> Disposable in
            FBSDKLoginKit.LoginManager().logOut()
            observer.onNext(.success(()))
            return Disposables.create()
        }
    }
}

extension FirebaseAuthentication: GoogleAuthenticationFeature {
    func logInWithGoogle() -> Observable<Result<ValueReturn, ErrorType>> {

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
                          let name = user.displayName,
                          let imageUrl = user.photoURL else {
                        observer.onNext(.failed("Not get user from google account"))
                        self.loadingService.hide()
                        return
                    }
                    self.saveAccountManager.setData(with: email, key: .email)
                    self.saveAccountManager.setData(with: name, key: .fullName)
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
                        KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: imageUrl)) { result in
                            switch result {
                            case .success(let value):
                                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                                    lastName: lastName,
                                                                                    emailAddress: email,
                                                                                    token: nil,
                                                                                    image: value.image))
                            case .failure:
                                observer.onNext(.failed("Fail to retrieve image"))
                            }
                        }
                    }
                    observer.onNext(.success(()))
                    self.loadingService.hide()
                }
            }
            return Disposables.create()
        }
    }

    func logOutGoogle() -> Observable<Result<ValueReturn, ErrorType>> {
        return Observable.create { observer -> Disposable in
            GIDSignIn.sharedInstance.signOut()
            observer.onNext(.success(()))
            return Disposables.create()
        }
    }
}
