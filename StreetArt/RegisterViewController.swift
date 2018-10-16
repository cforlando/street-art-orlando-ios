//
//  RegisterViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/28/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class RegisterViewController: UIViewController {

    struct GroupIdentifier {
        static let field = "FieldCell"
        static let agreement = "AgreementCell"
    }

    var tableView: UITableView!

    var dataSource = ContentSectionArray()

    var emailField: UITextField!
    var emailConfirmationField: UITextField!
    var nicknameField: UITextField!
    var passwordField: UITextField!

    var showPasswordButton: UIButton!

    var registerButton: UIButton!

    var footerView: UIView!

    var loginBlock: (() -> Void)?

    var acceptedTerms = false

    lazy var emptySet: CharacterSet = {
        return CharacterSet.whitespacesAndNewlines
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = REGISTER_TITLE
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.keyboardDismissMode = .interactive

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: CANCEL_TEXT,
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )

        emailField = UITextField()
        emailField.contentVerticalAlignment = .center
        emailField.keyboardType = .emailAddress
        emailField.returnKeyType = .done
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.placeholder = REGISTER_EMAIL_PLACEHOLDER
        emailField.delegate = self

        emailConfirmationField = UITextField()
        emailConfirmationField.contentVerticalAlignment = .center
        emailConfirmationField.keyboardType = .emailAddress
        emailConfirmationField.returnKeyType = .done
        emailConfirmationField.autocapitalizationType = .none
        emailConfirmationField.autocorrectionType = .no
        emailConfirmationField.placeholder = REGISTER_EMAIL_CONFIRMATION_PLACEHOLDER
        emailConfirmationField.delegate = self

        nicknameField = UITextField()
        nicknameField.contentVerticalAlignment = .center
        nicknameField.keyboardType = .default
        nicknameField.returnKeyType = .done
        nicknameField.autocapitalizationType = .words
        nicknameField.autocorrectionType = .no
        nicknameField.placeholder = REGISTER_NICKNAME_PLACEHOLDER
        nicknameField.delegate = self

        passwordField = UITextField()
        passwordField.contentVerticalAlignment = .center
        passwordField.keyboardType = .asciiCapable
        passwordField.returnKeyType = .done
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.isSecureTextEntry = true
        passwordField.placeholder = REGISTER_PASSWORD_PLACEHOLDER
        passwordField.delegate = self

        showPasswordButton = UIButton(type: .system)
        showPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
        showPasswordButton.setTitle(SHOW_PASSWORD_TEXT, for: .normal)

        let buttonWidth = showPasswordButton.titleLabel?.sizeThatFits(CGSize(width: 999.0, height: 999.0)).width ?? 0.0
        showPasswordButton.frame = CGRect(x: 0.0, y: 0.0, width: buttonWidth, height: 40.0)

        showPasswordButton.addTarget(self, action: #selector(showPasswordAction(_:)), for: .touchUpInside)

        passwordField.rightViewMode = .always
        passwordField.rightView = showPasswordButton

        // Footer

        registerButton = UIButton.highlightButton
        registerButton.setTitle(REGISTER_SUBMIT_BUTTON_TEXT, for: .normal)
        registerButton.addTarget(self, action: #selector(registerAction(_:)), for: .touchUpInside)

        let footerFrame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 84.0)
        footerView = UIView(frame: footerFrame)
        footerView.backgroundColor = .clear

        footerView.addSubview(registerButton)

        // Auto Layout

        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        registerButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-30.0)
            make.height.equalTo(44.0)
        }

        updateDataSource()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableFooterView = footerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

}

// MARK: -
// MARK: Methods

extension RegisterViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        content = ContentRow(object: emailField)
        content.groupIdentifier = GroupIdentifier.field

        rows.append(content)

        content = ContentRow(object: emailConfirmationField)
        content.groupIdentifier = GroupIdentifier.field

        rows.append(content)

        content = ContentRow(object: nicknameField)
        content.groupIdentifier = GroupIdentifier.field

        rows.append(content)

        content = ContentRow(object: passwordField)
        content.groupIdentifier = GroupIdentifier.field

        rows.append(content)

        content = ContentRow(text: nil)
        content.groupIdentifier = GroupIdentifier.agreement
        content.height = AgreementCell.defaultHeight

        rows.append(content)

        sections.append(ContentSection(title: nil, rows: rows))

        dataSource = sections
        tableView.reloadData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardShown(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardHidden(_:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    func displayAlert(message: String?, actions: [UIAlertAction]) {
        let alertView = UIAlertController(title: REGISTER_ALERT_TITLE, message: message, preferredStyle: .alert)

        for action in actions {
            alertView.addAction(action)
        }

        self.navigationController?.present(alertView, animated: true, completion: nil)
    }

}

// MARK: Selector Methods

extension RegisterViewController {

    @objc func registerAction(_ sender: AnyObject?) {
        self.view.endEditing(true)

        var messages = [String]()

        let email = (emailField.text ?? String()).trimmingCharacters(in: emptySet)
        let emailConfirmation = (emailConfirmationField.text ?? String()).trimmingCharacters(in: emptySet)
        let nickname = (nicknameField.text ?? String()).trimmingCharacters(in: emptySet)
        let password = (passwordField.text ?? String()).trimmingCharacters(in: emptySet)

        if email.isEmpty || emailConfirmation.isEmpty {
            messages.append(REGISTER_EMAIL_REQUIRED)
        }

        if email != emailConfirmation {
            messages.append(REGISTER_EMAIL_MATCH_ALERT)
        }

        if nickname.isEmpty {
            messages.append(REGISTER_NICKNAME_REQUIRED)
        }

        if password.isEmpty {
            messages.append(REGISTER_PASSWORD_REQUIRED)
        }

        if !messages.isEmpty {
            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            displayAlert(message: messages.joined(separator: "\n"), actions: [okAction])
            return
        }

        if !acceptedTerms {
            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            displayAlert(message: REGISTER_TERM_AGREE_ACCEPT_MESSAGE, actions: [okAction])
            return
        }

        HUD.show(.progress, onView: self.view)

        ApiClient.shared.register(email: email, password: password, nickname: nickname, name: nil) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            switch result {
            case .success(let success):
                guard success.success else {
                    HUD.hide()

                    let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                    self?.displayAlert(message: NETWORK_ERROR_TEXT, actions: [okAction])
                    return
                }

                LocalAnalytics.shared.customEvent(.registrationSuccess)

                ApiClient.shared.authenticate(username: email, password: password) { (loginResult) in
                    HUD.hide()

                    switch loginResult {
                    case .success:
                        NotificationCenter.default.post(name: .userDidLogin, object: nil)
                        self?.loginBlock?()
                        self?.navigationController?.dismiss(animated: true, completion: nil)
                    case .failure(let error):
                        let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                        self?.displayAlert(message: error.localizedDescription, actions: [okAction])
                    }
                }
            case .failure(let error):
                HUD.hide()

                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                self?.displayAlert(message: error.localizedDescription, actions: [okAction])
            }
        }
    }

    @objc func dismissAction(_ sender: AnyObject?) {
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func showPasswordAction(_ sender: AnyObject?) {
        let text = passwordField.text
        passwordField.text = nil

        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
        passwordField.text = text
    }

    @objc func keyboardShown(_ notification: NSNotification) {
        if let kbFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInset = tableView.contentInset
            contentInset.bottom = kbFrame.size.height

            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.contentInset = contentInset
            })
        }
    }

    @objc func keyboardHidden(_ notification: NSNotification) {
        var contentInset = tableView.contentInset
        contentInset.bottom = 0.0

        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.contentInset = contentInset
        })
    }

}

// MARK: - UITableViewDataSource Methods

extension RegisterViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.groupIdentifier ?? String()

        if identifier == GroupIdentifier.field {
            var cell = tableView.dequeueReusableCell(withIdentifier: GroupIdentifier.field)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: GroupIdentifier.field)
            }

            if let field = row.object as? UITextField {
                field.frame = CGRect(x: 15.0, y: 0.0, width: tableView.frame.size.width - 30.0, height: 40.0)
                cell?.accessoryView = field
            } else {
                cell?.accessoryView = nil
            }

            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == GroupIdentifier.agreement {
            var cell = tableView.dequeueReusableCell(withIdentifier: GroupIdentifier.agreement) as? AgreementCell
            if cell == nil {
                cell = AgreementCell(reuseIdentifier: GroupIdentifier.agreement)
                cell?.agreementSwitch.isOn = acceptedTerms
                cell?.agreementDelegate = self
            }

            return cell!
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension RegisterViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

}

// MARK: - AgreementCellDelegate

extension RegisterViewController: AgreementCellDelegate {

    func didChangeAgreement(cell: UITableViewCell, value: Bool) {
        dLog("dis change agreement")
        acceptedTerms = value
    }

    func didPressAgreementButton(cell: UITableViewCell) {
        let controller = WebViewController(url: URL(string: WebsiteURL.terms)!)

        controller.dismissBlock = { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }

        let navController = UINavigationController(rootViewController: controller)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }

}

// MARK: UITextFieldDelegate Methods

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
