//
//  DatabaseManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 28/04/2023.
//

import Foundation
import FirebaseDatabase
import RxSwift

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let token: String?
    let image: UIImage?

    func convertEmail() -> String {
        return emailAddress
            .replacingOccurrences(of: "@", with: "-")
            .replacingOccurrences(of: ".", with: "-")

    }

    var pictureData: Data {
        return image?.pngData() ?? Data()
    }

    var profilePictureFileName: String {
        ///  canh-gmail-com_profile_picture.png
        return "\(convertEmail())_profile_picture.png"
    }
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    private let disposeBag = DisposeBag()
    private let storageManager: StorageManager

    init(storageManager: StorageManager = StorageManager()) {
        self.storageManager = storageManager
    }

}

extension DatabaseManager {

    func userExists(with email: String, completion: @escaping (Bool) -> Void) {
        database.child(email).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    /// Insert a new user to database
    func insertUser(with user: ChatAppUser) {
        userExists(with: user.convertEmail()) { [weak self] isExist in
            guard let self = self else {
                return
            }
            if !isExist {
                self.database.child(user.convertEmail()).setValue(["firstName": user.firstName,
                                                            "lastName": user.lastName
                                                                   ], withCompletionBlock: { error, _ in
                    guard error == nil else {
                        return
                    }
                    // upload Image to Firebase
                    self.storageManager
                        .uploadProfilePicture(with: user.pictureData, fileName: user.profilePictureFileName)
                        .subscribe(onNext: { result in
                            switch result {
                            case .success(let url):
                                print("zzzzzzzzzz url", url)
                                UserDefaults.standard.set(url, forKey: "profile_picture_url")
                            case .failed:
                                print("Fail to upload profile picture to Firebase")
                            }
                        })
                        .disposed(by: self.disposeBag)
                })
            }
        }
    }
}
