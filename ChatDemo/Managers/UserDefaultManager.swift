//
//  UserDefaultManager.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import Foundation

protocol SaveToLocalFeature {
    associatedtype KeySave
    associatedtype Value
    func saveData(value: Any, key: KeySave)
    func getData(key: KeySave) -> Value?
}

class UserDefaultManager<Element>: SaveToLocalFeature {
    private let userDefault = UserDefaults.standard

    func saveData(value: Any, key: AppKey) {
        userDefault.setValue(value as? Element, forKey: key.rawValue)
    }

    func getData(key: AppKey) -> Element? {
        userDefault.value(forKey: key.rawValue) as? Element
    }
}
