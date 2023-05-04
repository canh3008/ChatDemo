//
//  ChatViewModel.swift
//  ChatDemo
//
//  Created by Duc Canh on 03/05/2023.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String

}

class ChatViewModel: BaseViewModel, ViewModelTransformable {

    func transform(input: Input) -> Output {
        return Output()
    }
}

extension ChatViewModel {
    struct Input {

    }

    struct Output {

    }
}
