//
//  String+Extention.swift
//  ChatDemo
//
//  Created by Duc Canh on 18/04/2023.
//

import Foundation

extension String {

    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }

    func isValidatePassword() -> Bool {
        let passwordRegEx = "[A-Z0-9a-z]{8,64}"

        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: self)
    }
}
