//
//  ProfileViewModel.swift
//  ChatDemo
//
//  Created by Duc Canh on 02/05/2023.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class ProfileViewModel: BaseViewModel, ViewModelTransformable {
    private let authentication: FirebaseAuthentication
    private let storageManager: StorageManager
    private let saveLocalManager: SaveAccountManager

    init(authentication: FirebaseAuthentication = FirebaseAuthentication(),
         storageManager: StorageManager = StorageManager(),
         saveLocalManager: SaveAccountManager = SaveAccountManager()) {
        self.authentication = authentication
        self.storageManager = storageManager
        self.saveLocalManager = saveLocalManager
    }

    func transform(input: Input) -> Output {
        let sections: [ProfileSection] = [.logoutSection(models: [.logout(title: "Logout")])]
        let models = Observable.just(sections)
            .asDriverOnErrorJustComplete()

        let requestLogOutEmail = input
            .selectedItem
            .flatMapLatest { [weak self] profile -> Observable<Result<FirebaseAuthentication.ValueReturn, FirebaseAuthentication.ErrorType>> in
                guard let self = self else {
                    return .empty()
                }
                switch profile {
                case .logout:
                    return self.authentication.logOutEmail()
                }
            }
            .share()

        let logOutEmailSuccess = requestLogOutEmail
            .mapGetResultSuccess()

        let error = requestLogOutEmail
            .mapGetMessageError()
            .asDriverOnErrorJustComplete()

        let requestLogOutFacebook = input
            .selectedItem
            .flatMapLatest { [weak self] profile -> Observable<Result<FirebaseAuthentication.ValueReturn, FirebaseAuthentication.ErrorType>> in
                guard let self = self else {
                    return .empty()
                }
                switch profile {
                case .logout:
                    return self.authentication.logOutFacebook()
                }
            }
            .mapGetResultSuccess()

        let requestLogOutGoogle = input
            .selectedItem
            .flatMapLatest { [weak self] profile -> Observable<Result<FirebaseAuthentication.ValueReturn, FirebaseAuthentication.ErrorType>> in
                guard let self = self else {
                    return .empty()
                }
                switch profile {
                case .logout:
                    return self.authentication.logOutGoogle()
                }
            }
            .share()

        let logOutGoogleSuccess = requestLogOutGoogle
            .mapGetResultSuccess()

        let logOutSuccess = Observable.combineLatest(logOutEmailSuccess, requestLogOutFacebook, logOutGoogleSuccess)
            .filter({ $0 && $1 && $2})
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let getImageUrl = Observable.just(saveLocalManager.getData(key: .pictureFileName))
            .map({ "/images/\($0)" })
            .flatMapLatest({
                self.storageManager.downloadURL(for: $0)
            })
            .mapGetResultValue()
            .compactMap({ URL(string: $0) })
            .asDriverOnErrorJustComplete()

        return Output(models: models,
                      logOutSuccess: logOutSuccess,
                      error: error,
                      profilePictureUrl: getImageUrl)
    }
}

extension ProfileViewModel {
    struct Input {
        let selectedItem: Observable<Profile>
    }

    struct Output {
        let models: Driver<[ProfileSection]>
        let logOutSuccess: Driver<Void>
        let error: Driver<String>
        let profilePictureUrl: Driver<URL>
    }
}

enum Profile: IdentifiableType, Equatable {
    var identity: Int {
        return 0
    }

    typealias Identity = Int

    case logout(title: String)
}

enum ProfileSection {
    case logoutSection(models: [Profile])

    var header: String {
        switch self {
        case .logoutSection:
            return ""
        }
    }
    var items: [Profile] {
        switch self {
        case .logoutSection(let models):
            return models
        }
    }
}

extension ProfileSection: AnimatableSectionModelType {
    var identity: Int {
        return 0
    }

    typealias Identity = Int

    init(original: ProfileSection, items: [Profile]) {
        self = original
        switch self {
        case .logoutSection:
            self = .logoutSection(models: items)
        }
    }
}
