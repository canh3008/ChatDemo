//
//  Theme.swift
//  ChatDemo
//
//  Created by Duc Canh on 20/04/2023.
//

import Foundation
import SwifterSwift

enum Theme: String {
    case error = "Error" // #FF4B1E
    case disable = "Disable" // #AAAAAA

    var color: UIColor {
        return UIColor(named: rawValue)  ?? .green
    }
}
