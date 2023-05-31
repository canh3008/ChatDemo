//
//  Dictionary+Extension.swift
//  ChatDemo
//
//  Created by Duc Canh on 05/05/2023.
//

import Foundation

extension Dictionary {
    func castToObject<T: Decodable>() -> T? {
        let json = try? JSONSerialization.data(withJSONObject: self)
        return json == nil ? nil : try? JSONDecoder().decode(T.self, from: json!)
    }
}

extension Array {
    func castToObject<T: Decodable>() -> [T]? {
        let json = try? JSONSerialization.data(withJSONObject: self)
        return json == nil ? nil : try? JSONDecoder().decode([T].self, from: json!)
    }
}
