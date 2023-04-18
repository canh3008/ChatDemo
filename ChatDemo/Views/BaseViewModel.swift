//
//  BaseViewModel.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import Foundation

protocol ViewModelTransformable {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

class BaseViewModel {
   
}
