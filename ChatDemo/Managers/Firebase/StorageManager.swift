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
    func downloadURL(for path: String) -> Observable<Result<ValueReturn, ErrorType>>
}

class StorageManager: StorageFeature {
    typealias ErrorType = String
    typealias ValueReturn = String

    private let storage = Storage.storage().reference()
    private let saveLocalManager: SaveAccountManager

    init(saveLocalManager: SaveAccountManager = SaveAccountManager()) {
        self.saveLocalManager = saveLocalManager
    }

    /*
     /images/canh-gmail-com_profile_picture.png
     */

    func uploadProfilePicture(with data: Data, fileName: String) -> Observable<Result<ValueReturn, ErrorType>> {
        return Observable.create { observer -> Disposable in
            self.storage.child("/images/\(fileName)").putData(data) { _, error in
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
                    self.saveLocalManager.setData(with: fileName, key: .pictureFileName)
                    observer.onNext(.success(urlString))
                }
            }
            return Disposables.create()
        }
    }

    func downloadURL(for path: String) -> Observable<Result<ValueReturn, ErrorType>> {
        let reference = storage.child(path)
        return Observable.create { observer -> Disposable in
            reference.downloadURL { url, error in
                guard let url = url?.absoluteString, error == nil else {
                    observer.onNext(.failed(error?.localizedDescription ?? "Nil"))
                    return
                }
                observer.onNext(.success(url))
            }
            return Disposables.create()
        }
    }
}
