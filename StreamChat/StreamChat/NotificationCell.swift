//
//  NotificationCell.swift
//  StreamChat
//
//  Created by 기원우 on 2021/08/18.
//

import UIKit
import SnapKit

final class NotificationCell: UITableViewCell {
    static let reuseIdentifier = "notificationCell"

    private let notificationLable: UILabel = {
        let label = UILabel()
        return label
    }()

    func setupNotificationLabel(message: String) {
        addSubview(notificationLable)
        notificationLable.text = message

        notificationLable.snp.makeConstraints { label in
            label.centerX.equalTo(self)
            label.top.bottom.equalTo(self)
        }
    }
}
