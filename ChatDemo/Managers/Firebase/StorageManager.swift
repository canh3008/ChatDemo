//
//  StorageManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 03/05/2023.
//

import Foundation
import FirebaseStorage
import RxSwift

protocol UploadPhotoFeature {
    associatedtype ValueReturns
}

protocol StorageFeature: AuthenticationFeature, UploadPhotoFeature {
    func uploadProfilePicture(with data: Data, fileName: String) -> Observable<Result<ValueReturn, ErrorType>>
    func downloadURL(for path: String) -> Observable<Result<ValueReturn, ErrorType>>
    func uploadMessagePhotos(data infos: [InfoPhoto]) -> Observable<Result<ValueReturns, ErrorType>>
}

class StorageManager: StorageFeature {
    typealias ErrorType = String
    typealias ValueReturn = String
    typealias ValueReturns = [String]

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

    func uploadMessagePhotos(data infos: [InfoPhoto]) -> Observable<Result<ValueReturns, ErrorType>> {
        return Observable.create { observer -> Disposable in
            let group = DispatchGroup()
            var urls: [String] = []
            infos.forEach { info in
                group.enter()
                self.storage.child("/message_photos/\(info.fileName)").putData(info.data) { _, error in
                    guard error == nil else {
                        observer.onNext(.failed(error?.localizedDescription ?? "Nil"))
                        return
                    }
                    self.storage.child("/message_photos/\(info.fileName)").downloadURL { url, error in
                        guard error == nil, let url = url else {
                            observer.onNext(.failed(error?.localizedDescription ?? "Nil"))
                            return
                        }
                        let urlString = url.absoluteString
                        urls.append(urlString)
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                observer.onNext(.success(urls))
            }
            return Disposables.create()
        }
    }
}
