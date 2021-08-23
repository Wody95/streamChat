//
//  MyMessageCell.swift
//  StreamChat
//
//  Created by 기원우 on 2021/08/17.
//

import UIKit
import SnapKit

final class MyMessageCell: UITableViewCell {
    static let reuseIfentifier = "myMessageCell"

    private let messageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bubble_right")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleToFill
        imageView.tintColor = .systemGreen
        return imageView
    }()

    private let messageLable: UILabel = {
        let label = UILabel()
        label.text = "placeholder send Message"
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "receive Time"
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        return label
    }()

    func setupMessage(message: String, time: Date) {
        contentView.addSubview(messageView)
        contentView.addSubview(messageLable)
        contentView.addSubview(timeLabel)

        messageLable.text = message
        timeLabel.text = DateToStringFormatter.shared.dateToStringTime(at: time)

        messageView.snp.makeConstraints { imageView in
            imageView.top.equalToSuperview().inset(5)
            imageView.trailing.equalTo(self).inset(5)
            imageView.leading.greaterThanOrEqualTo(self).inset(100)
        }

        messageLable.snp.makeConstraints { label in
            label.top.bottom.equalTo(messageView).inset(5)
            label.leading.equalTo(messageView).inset(10)
            label.trailing.equalTo(messageView).inset(13)
        }

        timeLabel.snp.makeConstraints { label in
            label.top.equalTo(messageView.snp.bottom).offset(3)
            label.trailing.equalTo(messageLable.snp.trailing).offset(3)
            label.bottom.equalToSuperview().inset(5)
        }
    }
}
