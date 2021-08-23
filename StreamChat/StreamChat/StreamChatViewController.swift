//
//  StreamChat - StreamChatViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import SnapKit

final class StreamChatViewController: UIViewController {
    private unowned var bottomConstraint = NSLayoutConstraint()
    private let tableView = UITableView()
    private let sendMessageView = SendMessageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        StreamChat.shared.delegate = self
        view.backgroundColor = .systemBackground
        self.navigationController?.isNavigationBarHidden = false
        setupKeyboardWillShow()
        setupKeyboardWillHide()
        setupTableView()
        setupSendMessageView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        StreamChat.shared.stopChat()
        self.navigationController?.isNavigationBarHidden = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    private func setupKeyboardWillShow() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil, queue: .main) { [weak self] notification in
            guard let userInfo = notification.userInfo else { return }

            guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                  let self = self else { return }

            self.bottomConstraint.constant = -keyboardFrame.height + 35

            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            } completion: { (completion) in
                self.scrollToBottom()
            }
        }
    }

    private func setupKeyboardWillHide() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil, queue: .main) { [weak self] notification in
            guard let userInfo = notification.userInfo else { return }
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                  let self = self else { return }

            self.bottomConstraint.constant = 0

            UIView.animate(withDuration: duration) {
                self.view.setNeedsLayout()
            } completion: { (completion) in
                self.scrollToBottom()
            }
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.register(MyMessageCell.self, forCellReuseIdentifier: MyMessageCell.reuseIfentifier)
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: OtherMessageCell.reuseIdentifier)
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseIdentifier)

        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { tableView in
            tableView.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupSendMessageView() {
        view.addSubview(sendMessageView)

        sendMessageView.delegate = self
        sendMessageView.snp.makeConstraints { sendView in
            sendView.height.equalTo(70)
            sendView.top.equalTo(tableView.snp.bottom)
            sendView.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        bottomConstraint = sendMessageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                                   constant: .zero)
        bottomConstraint.isActive = true
    }

    private func scrollToBottom() {
        let lastRow: Int = StreamChat.shared.countChats() - 1

        if lastRow > 0 {
            let indexPath: IndexPath = IndexPath(row: lastRow, section: 0)
            tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
}

// MARK: - TableView DataSource
extension StreamChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StreamChat.shared.countChats()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chat = StreamChat.shared.readChats(at: indexPath.row) else {
            return UITableViewCell()
        }

        switch chat.identifier {
        case .my:
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MyMessageCell.reuseIfentifier,
                    for: indexPath) as? MyMessageCell else { return UITableViewCell() }
            cell.setupMessage(message: chat.message, time: chat.date)

            return cell
        case .other:
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: OtherMessageCell.reuseIdentifier,
                    for: indexPath) as? OtherMessageCell else { return UITableViewCell() }
            cell.setupMessage(message: chat.message, time: chat.date, username: chat.username)

            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: NotificationCell.reuseIdentifier,
                    for: indexPath) as? NotificationCell else { return UITableViewCell() }
            cell.setupNotificationLabel(message: chat.message)
            return cell
        }
    }
}

protocol StreamChatViewControllerDelegate {
    func insertMessage()
    func presentAlert(alert: UIAlertController)
}

extension StreamChatViewController: StreamChatViewControllerDelegate {
    func insertMessage() {
        let lastRow: Int = StreamChat.shared.countChats() - 1
        let indexPath: IndexPath = IndexPath(row: lastRow, section: 0)
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.none)
        tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
    }

    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
