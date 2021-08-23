//
//  StreamDataFormat.swift
//  StreamChat
//
//  Created by 기원우 on 2021/08/16.
//

import Foundation

struct StreamDataFormat {
    static let shared = StreamDataFormat()

    let divisionPoint = "::"
    let divisionNotifi = "has"
    let emptyUsername = ""
    let maxSendMessageLength = 300

    func join(data: String) -> String {
        return "USR_NAME::\(data)::END"
    }

    func sendMessage(data: String) -> String {
        return "MSG::\(data)::END"
    }

    func receiveMessage(username: String, message: String) -> String {
        return "\(username) : \(message)"
    }

    func notificationMessage(username: String, status: String) -> String {
        return "\(username) has \(status)"
    }

    func leave() -> String {
        return "LEAVE::::END"
    }
}
