//
//  StreamChat.swift
//  StreamChat
//
//  Created by 기원우 on 2021/08/12.
//

import Foundation

final class StreamChat: NSObject {
    static let shared = StreamChat()

    private var inputStream: InputStream?
    private var outputStream: OutputStream?

    private let maxReadLength = 4096
    private let maxSendMessageLength = 300
    private let receiveMessageCount = 2
    private var myUsername = StreamDataFormat.shared.emptyUsername
    private var chats: [Chat] = []

    var delegate: StreamChatViewControllerDelegate?

    func setupNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           StreamInfomation.host,
                                           StreamInfomation.port,
                                           &readStream,
                                           &writeStream)

        inputStream = readStream?.takeRetainedValue()
        outputStream = writeStream?.takeRetainedValue()

        inputStream?.delegate = self
        inputStream?.schedule(in: .current, forMode: .common)
        outputStream?.schedule(in: .current, forMode: .common)

        inputStream?.open()
        outputStream?.open()
    }

    private func stringToOutputStreamData(string: String) {
        guard let data = string.data(using: .utf8) else { return }

        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
            outputStream?.write(pointer, maxLength: data.count)
        }
    }

    func joinChat(username: String) {
        self.myUsername = username
        let data = StreamDataFormat.shared.join(data: username)
        stringToOutputStreamData(string: data)
    }

    func sendChat(message: String) {
        if message.count < maxSendMessageLength {
            let data = StreamDataFormat.shared.sendMessage(data: message)

            chats.append(Chat(username: myUsername,
                              message: message,
                              identifier: .my,
                              date: Date()))
            stringToOutputStreamData(string: data)
        } else {
            print("message limit over")
        }
    }

    private func receiveChat(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)

        while stream.hasBytesAvailable {
            guard let numberOfBytesRead = inputStream?.read(buffer,
                                                            maxLength: maxReadLength) else { return }

            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }

            processedMessagedString(buffer: buffer, length: numberOfBytesRead)
        }
    }

    func stopChat() {
        let data = StreamDataFormat.shared.leave()

        stringToOutputStreamData(string: data)
        inputStream?.close()
        outputStream?.close()

        self.chats = []
        self.myUsername = StreamDataFormat.shared.emptyUsername
    }

    func countChats() -> Int {
        return chats.count
    }

    func readChats(at index: Int) -> Chat? {
        if index >= chats.count {
            return nil
        }

        return chats[index]
    }
}

extension StreamChat: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            guard let inputStream = aStream as? InputStream else { return }
            receiveChat(stream: inputStream)
        case .endEncountered:
            stopChat()
        default:
            print("unknown Event")
        }
    }

    private func processedMessagedString(buffer: UnsafeMutablePointer<UInt8>, length: Int) {
        guard let stringArray = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding: .utf8,
                                       freeWhenDone: true)?
                .components(separatedBy: StreamDataFormat.shared.divisionPoint) else { return }

        if stringArray.count == receiveMessageCount {
            guard let username = stringArray.first,
                  let message = stringArray.last,
                  self.myUsername != username else { return }

            chats.append(Chat(username: username,
                              message: message,
                              identifier: .other, date: Date()))
        } else {
            guard let stringNotification = stringArray.first?
                    .components(separatedBy: StreamDataFormat.shared.divisionNotifi),
                  let username = stringNotification.first,
                  let status = stringNotification.last,
                  self.myUsername != username else { return }

            let notificationMessage = StreamDataFormat.shared.notificationMessage(username: username,
                                                                                  status: status)
            chats.append(Chat(username: username,
                              message: notificationMessage,
                              identifier: .notification,
                              date: Date()))
        }
        delegate?.insertMessage()
    }
}
