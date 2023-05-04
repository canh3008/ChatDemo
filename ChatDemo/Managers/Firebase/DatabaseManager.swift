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

    func convertEmail() -> String {
        return emailAddress
            .replacingOccurrences(of: "@", with: "-")
            .replacingOccurrences(of: ".", with: "-")

    }
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()

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
            if !isExist {
                self?.database.child(user.convertEmail()).setValue(["firstName": user.firstName,
                                                            "lastName": user.lastName
                                                           ])
            }
        }
    }
}
