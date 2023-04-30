//
//  DatabaseManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 28/04/2023.
//

import Foundation
import FirebaseDatabase

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String

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

    /// Insert a new user to database
    func insertUser(with user: ChatAppUser) {
        database.child(user.convertEmail()).setValue(["firstName": user.firstName,
                                                    "lastName": user.lastName
                                                   ])
    }
}
