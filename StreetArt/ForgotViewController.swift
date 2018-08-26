//
//  ForgotViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 5/16/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class ForgotViewController: UITableViewController {

    enum Step: String {
        case email = "email"
        case validate = "validate"
        case password = "password"
    }

    let FieldCellIdentifier = "FieldCell"

    var emailField: UITextField!
    var tokenField: UITextField!
    var passwordField: UITextField!

    var showPasswordButton: UIButton!

    var step = Step.email

    var emailString: String?
    var tokenString: String?
    var passwordString: String?

    var dataSource = ContentSectionArray()

    lazy var emptySet: CharacterSet = {
        return CharacterSet.whitespacesAndNewlines
    }()

    convenience init() {
        self.init(step: .email)
    }

    init(step: Step) {
        super.init(nibName: nil, bundle: nil)
        self.title = FORGOT_TITLE
        self.step = step
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.dataSource = self
        self.tableView.delegate = self
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

        updateSubmitButton()

        emailField = UITextField()
        emailField.contentVerticalAlignment = .center
        emailField.keyboardType = .emailAddress
        emailField.returnKeyType = .done
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.placeholder = FORGOT_EMAIL_PLACEHOLDER

        tokenField = UITextField()
        tokenField.contentVerticalAlignment = .center
        tokenField.keyboardType = .numberPad
        tokenField.returnKeyType = .done
        tokenField.autocapitalizationType = .words
        tokenField.autocorrectionType = .no
        tokenField.placeholder = FORGOT_TOKEN_PLACEHOLDER

        passwordField = UITextField()
        passwordField.contentVerticalAlignment = .center
        passwordField.keyboardType = .asciiCapable
        passwordField.returnKeyType = .done
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.isSecureTextEntry = true
        passwordField.placeholder = FORGOT_PASSWORD_PLACEHOLDER

        showPasswordButton = UIButton(type: .system)
        showPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
        showPasswordButton.setTitle(SHOW_PASSWORD_TEXT, for: .normal)

        let buttonWidth = showPasswordButton.titleLabel?.sizeThatFits(CGSize(width: 999.0, height: 999.0)).width ?? 0.0
        showPasswordButton.frame = CGRect(x: 0.0, y: 0.0, width: buttonWidth, height: 40.0)

        showPasswordButton.addTarget(self, action: #selector(showPasswordAction(_:)), for: .touchUpInside)

        passwordField.rightViewMode = .always
        passwordField.rightView = showPasswordButton

        updateDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: Methods

extension ForgotViewController {

    func updateSubmitButton() {
        var titleStr = String()

        switch step {
        case .password:
            titleStr = RESET_TEXT
        default:
            titleStr = SUBMIT_TEXT
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: titleStr,
            style: .done,
            target: self,
            action: #selector(submitAction(_:))
        )
    }

    func update(step: Step?) {
        if let step = step {
            switch step {
            case .validate:
                LocalAnalytics.shared.forgotPasswordStepSecurityCode()
            case .password:
                LocalAnalytics.shared.forgotPasswordStepPasswordUpdate()
            default:
                break
            }

            self.step = step
        }

        updateSubmitButton()
        updateDataSource()
    }

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        switch step {
        case .email:
            content = ContentRow(text: FORGOT_EMAIL_TEXT)
            content.object = emailField
        case .validate:
            content = ContentRow(text: FORGOT_VALIDATE_TEXT)
            content.object = tokenField
        case .password:
            content = ContentRow(text: FORGOT_PASSWORD_TEXT)
            content.object = passwordField
        }

        content.groupIdentifier = FieldCellIdentifier

        rows.append(content)

        sections.append(ContentSection(title: nil, rows: rows))

        dataSource = sections
        self.tableView.reloadData()
    }

    func submitEmail() {
        let email = (emailField.text ?? String()).trimmingCharacters(in: emptySet).lowercased()
        if email.isEmpty {
            self.view.endEditing(true)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            displayAlert(message: FORGOT_EMAIL_REQUIRED, actions: [okAction])
            return
        }

        self.view.endEditing(true)

        HUD.show(.progress, onView: self.view)

        ApiClient.shared.passwordForgot(email: email) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            HUD.hide()

            switch result {
            case .success(let response):
                var alertMessage: String?
                var alertAction: UIAlertAction?

                if response.success {
                    if let message = response.message {
                        alertMessage = message
                        alertAction = UIAlertAction(title: OK_TEXT, style: .cancel) { (action) in
                            self?.emailString = email
                            self?.update(step: .validate)
                        }
                    } else {
                        // This code should never run but leaving it here for completeness
                        self?.emailString = email
                        self?.update(step: .validate)
                    }
                } else {
                    if let message = response.message {
                        alertMessage = message
                    } else {
                        alertMessage = NETWORK_ERROR_TEXT
                    }

                    alertAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                }

                if let action = alertAction {
                    self?.displayAlert(message: alertMessage, actions: [action])
                }
            case .failure(let error):
                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                self?.displayAlert(message: error.localizedDescription, actions: [okAction])
            }
        }
    }

    func submitValidate() {
        let email = emailString ?? String()
        if email.isEmpty {
            self.view.endEditing(true)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel) { [unowned self] (action) in
                self.update(step: .email)
            }

            displayAlert(message: FORGOT_EMAIL_REQUIRED, actions: [okAction])
            return
        }

        let token = (tokenField.text ?? String()).trimmingCharacters(in: emptySet).replacingOccurrences(of: " ", with: "")
        if token.isEmpty {
            self.view.endEditing(true)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            displayAlert(message: FORGOT_TOKEN_REQUIRED, actions: [okAction])
            return
        }

        self.view.endEditing(true)

        HUD.show(.progress, onView: self.view)

        ApiClient.shared.passwordValidateToken(email: email, token: token) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            HUD.hide()

            switch result {
            case .success(let response):
                if response.success {
                    self?.tokenString = token
                    self?.update(step: .password)
                } else {
                    var alertMessage: String

                    if let message = response.message {
                        alertMessage = message
                    } else {
                        alertMessage = NETWORK_ERROR_TEXT
                    }

                    let alertAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                    self?.displayAlert(message: alertMessage, actions: [alertAction])
                }
            case .failure(let error):
                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                self?.displayAlert(message: error.localizedDescription, actions: [okAction])
            }
        }
    }

    func submitPassword() {
        let email = emailString ?? String()
        if email.isEmpty {
            self.view.endEditing(true)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel) { [unowned self] (action) in
                self.update(step: .email)
            }

            displayAlert(message: FORGOT_EMAIL_REQUIRED, actions: [okAction])
            return
        }

        let token = tokenString ?? String()
        if token.isEmpty {
            self.view.endEditing(true)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel) { [unowned self] (action) in
                self.update(step: .email)
            }

            displayAlert(message: FORGOT_TOKEN_REQUIRED, actions: [okAction])
            return
        }

        let password = (passwordField.text ?? String()).trimmingCharacters(in: emptySet)
        if password.isEmpty {
            self.view.endEditing(true)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            displayAlert(message: FORGOT_PASSWORD_REQUIRED, actions: [okAction])
            return
        }

        self.view.endEditing(true)

        HUD.show(.progress, onView: self.view)

        ApiClient.shared.passwordReset(email: email, token: token, password: password) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            HUD.hide()

            switch result {
            case .success(let response):
                if response.success {
                    LocalAnalytics.shared.forgotPasswordSuccess()
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                } else {
                    var alertMessage: String

                    if let message = response.message {
                        alertMessage = message
                    } else {
                        alertMessage = NETWORK_ERROR_TEXT
                    }

                    let alertAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                    self?.displayAlert(message: alertMessage, actions: [alertAction])
                }
            case .failure(let error):
                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                self?.displayAlert(message: error.localizedDescription, actions: [okAction])
            }
        }
    }

    func displayAlert(message: String?, actions: [UIAlertAction]) {
        let alertView = UIAlertController(title: FORGOT_ALERT_TITLE, message: message, preferredStyle: .alert)

        for action in actions {
            alertView.addAction(action)
        }

        self.navigationController?.present(alertView, animated: true, completion: nil)
    }

}

// MARK: Selector Methods

extension ForgotViewController {

    @objc func submitAction(_ sender: AnyObject?) {
        switch step {
        case .email:
            submitEmail()
        case .validate:
            submitValidate()
        case .password:
            submitPassword()
        }
    }

    @objc func dismissAction(_ sender: AnyObject?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func showPasswordAction(_ sender: AnyObject?) {
        let text = passwordField.text
        passwordField.text = nil

        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
        passwordField.text = text
    }

}

// MARK: - UITableViewDataSource Methods

extension ForgotViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.groupIdentifier ?? String()

        if identifier == FieldCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: FieldCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: FieldCellIdentifier)
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            }

            cell?.textLabel?.text = row.text

            if let field = row.object as? UITextField {
                field.frame = CGRect(x: 15.0, y: 0.0, width: tableView.frame.size.width - 150.0, height: 40.0)
                cell?.accessoryView = field
            } else {
                cell?.accessoryView = nil
            }

            cell?.selectionStyle = .none

            return cell!
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: - UITableViewDelegate Methods

extension ForgotViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
