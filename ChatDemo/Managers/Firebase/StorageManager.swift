//
//  StorageManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 03/05/2023.
//

import Foundation
import FirebaseStorage
import RxSwift

protocol StorageFeature: AuthenticationFeature {
    func uploadProfilePicture(with data: Data, fileName: String) -> Observable<Result<ValueReturn, ErrorType>>
}

class StorageManager: StorageFeature {
    typealias ErrorType = String
    typealias ValueReturn = String

    private let storage = Storage.storage().reference()
    private let loadingService: LoadingFeature

    init(loadingService: LoadingFeature = LoadingService()) {
        self.loadingService = loadingService
    }

    /*
     /images/canh-gmail-com_profile_picture.png
     */

    func uploadProfilePicture(with data: Data, fileName: String) -> Observable<Result<ValueReturn, ErrorType>> {
        loadingService.show()
        return Observable.create { observer -> Disposable in
            self.storage.child("/images/\(fileName)").putData(data) { metaData, error in
                guard error == nil else {
                    observer.onNext(.failed(error?.localizedDescription ?? "Nil"))
                    return
                }
                self.storage.child("/images/\(fileName)").downloadURL { url, error in
                    guard error == nil, let url = url else {
                        observer.onNext(.failed(error?.localizedDescription ?? "Nil"))
                        return
                    }
                    let urlString = url.absoluteString
                    observer.onNext(.success(urlString))
                    self.loadingService.hide()
                }
            }
            return Disposables.create()
        }
    }
}
