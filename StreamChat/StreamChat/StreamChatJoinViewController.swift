//
//  StreamChatJoinViewController.swift
//  StreamChat
//
//  Created by 기원우 on 2021/08/17.
//

import UIKit
import SnapKit

final class StreamChatJoinViewController: UIViewController {
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray4
        textField.leftView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 10,
                                                  height: textField.frame.height))
        textField.leftViewMode = .always
        textField.placeholder = "10글자 이내의 닉네임 입력"
        return textField
    }()

    private let joinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join", for: .normal)
        button.backgroundColor = .systemBackground
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapJoinButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationController?.isNavigationBarHidden = true
        setupJoinButton()
        setupUsernameTextField()
    }

    private func setupUsernameTextField() {
        view.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { textField in
            textField.centerY.equalTo(view.safeAreaLayoutGuide)
            textField.leading.equalTo(view.safeAreaLayoutGuide).inset(30)
            textField.trailing.equalTo(joinButton.snp.leading)
            textField.height.equalTo(50)

        }
    }

    private func setupJoinButton() {
        view.addSubview(joinButton)
        joinButton.snp.makeConstraints { button in
            button.centerY.equalTo(view.safeAreaLayoutGuide)
            button.width.equalTo(50)
            button.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    @objc func didTapJoinButton() {
        if let text = usernameTextField.text, text.isEmpty == false, text.count <= 10 {
            let streamChatViewController = StreamChatViewController()

            self.navigationController?.pushViewController(streamChatViewController, animated: true)
            StreamChat.shared.setupNetworkCommunication()
            StreamChat.shared.joinChat(username: text)
            usernameTextField.text = nil
        } else {
            let alert = UIAlertController(title: "닉네임 글자수 초과!",
                                          message: "닉네임은 10글자 이하로 해주세요",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true) {
                self.usernameTextField.text = nil
            }
        }
    }
}
