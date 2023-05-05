//
//  SaveAccountManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 05/05/2023.
//

import Foundation

enum KeySave: String {
    case email = "email_account"
    case pictureFileName = "picture_file_name"
}

protocol SaveDataLocalFeature {
    associatedtype Value
    func setData(with value: Value, key: KeySave)
    func getData(key: KeySave) -> Value
    func removeData(key: KeySave)
}

class SaveAccountManager: SaveDataLocalFeature {

    private let userDefault = UserDefaults.standard

    func setData(with value: String, key: KeySave) {
        userDefault.set(value, forKey: key.rawValue)
    }

    func getData(key: KeySave) -> String {
        guard let data = userDefault.value(forKey: key.rawValue) as? String else {
            return ""
        }
        return data
    }

    func removeData(key: KeySave) {
        userDefault.removeObject(forKey: key.rawValue)
    }
}
