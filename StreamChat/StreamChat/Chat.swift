//
//  Chat.swift
//  StreamChat
//
//  Created by 기원우 on 2021/08/17.
//

import Foundation

enum Identifier {
    case my
    case other
    case notification
}

struct Chat {
    let username: String
    let message: String
    let identifier: Identifier
    let date: Date
}
