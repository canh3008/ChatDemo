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
    case primaryBorder = "PrimaryBorder" // #D4D9D6
    case primaryTintColor = "PrimaryTintColor" // #0579FF
    case secondTintColor = "SecondTintColor" // #C2C3C3

    var color: UIColor {
        return UIColor(named: rawValue)  ?? .green
    }
}
