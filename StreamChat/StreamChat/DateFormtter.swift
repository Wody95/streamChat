//
//  DateFormtter.swift
//  StreamChat
//
//  Created by 기원우 on 2021/08/17.
//

import Foundation

final class DateToStringFormatter {
    static let sherd = DateToStringFormatter()

    let dateFormatter = DateFormatter()

    func dateToStringTime(at date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        return dateFormatter.string(from: date)
    }
}
