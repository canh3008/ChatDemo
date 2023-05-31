//
//  Date+Extension.swift
//  ChatDemo
//
//  Created by Duc Canh on 07/05/2023.
//

import Foundation

extension Date {

    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter.string(from: self)
    }
}
