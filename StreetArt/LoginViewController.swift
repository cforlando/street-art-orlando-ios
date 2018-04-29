//
//  LoginViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/28/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class LoginViewController: UIViewController {

    let FieldCellIdentifier = "FieldCell"

    var tableView: UITableView!

    var usernameField: UITextField!
    var passwordField: UITextField!

    var loginButton: UIButton!
    var forgotPasswordButton: UIButton!

    var footerView: UIView!

    var dataSource = ContentSectionArray()

    var loginBlock: (() -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = LOGIN_TITLE
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

        tableView.keyboardDismissMode = .interactive

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: CANCEL_TEXT,
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )

        usernameField = UITextField()
        usernameField.contentVerticalAlignment = .center
        usernameField.keyboardType = .emailAddress
        usernameField.returnKeyType = .done
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.placeholder = LOGIN_USERNAME_PLACEHOLDER
        usernameField.delegate = self

        passwordField = UITextField()
        passwordField.contentVerticalAlignment = .center
        passwordField.keyboardType = .asciiCapable
        passwordField.returnKeyType = .done
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.isSecureTextEntry = true
        passwordField.placeholder = LOGIN_PASSWORD_PLACEHOLDER
        passwordField.delegate = self

        // Footer

        loginButton = UIButton.highlightButton
        loginButton.setTitle(LOGIN_SUBMIT_BUTTON_TEXT, for: .normal)
        loginButton.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)

        forgotPasswordButton = UIButton(type: .system)
        forgotPasswordButton.setTitle(LOGIN_FORGOT_PASSWORD_BUTTON_TEXT, for: .normal)

        let footerFrame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 124.0)
        footerView = UIView(frame: footerFrame)
        footerView.backgroundColor = .clear

        footerView.addSubview(loginButton)
        footerView.addSubview(forgotPasswordButton)

        // Auto Layout

        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        loginButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-30.0)
            make.height.equalTo(44.0)
        }

        forgotPasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(30.0)
            make.centerX.equalToSuperview()
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

}

// MARK: -
// MARK: Methods

extension LoginViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        content = ContentRow(object: usernameField)
        content.groupIdentifier = FieldCellIdentifier

        rows.append(content)

        content = ContentRow(object: passwordField)
        content.groupIdentifier = FieldCellIdentifier

        rows.append(content)

        sections.append(ContentSection(title: nil, rows: rows))

        dataSource = sections
        tableView.reloadData()
    }

}

// MARK: Selector Methods

extension LoginViewController {

    @objc func loginAction(_ sender: AnyObject?) {
        self.view.endEditing(true)

        let username = usernameField.text ?? String()
        let password = passwordField.text ?? String()

        if username.isEmpty || password.isEmpty {
            let alertView = UIAlertController(
                title: LOGIN_ERROR_ALERT_TITLE,
                message: LOGIN_ERROR_MISSING_ALERT_MESSAGE,
                preferredStyle: .alert
            )

            let doneAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(doneAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
            return
        }

        HUD.show(.progress, onView: self.view)
        ApiClient.shared.authenticate(username: username, password: password) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            HUD.hide()

            switch result {
            case .success:
                NotificationCenter.default.post(name: .userDidLogin, object: nil)
                self?.loginBlock?()
                self?.navigationController?.dismiss(animated: true, completion: nil)
            case .failure:
                let alertView = UIAlertController(
                    title: LOGIN_ERROR_ALERT_TITLE,
                    message: LOGIN_ERROR_FAIL_ALERT_MESSAGE,
                    preferredStyle: .alert
                )

                let doneAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertView.addAction(doneAction)

                self?.navigationController?.present(alertView, animated: true, completion: nil)
            }
        }
    }

    @objc func dismissAction(_ sender: AnyObject?) {
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func forgotAction(_ sender: AnyObject?) {
        
    }

}

// MARK: - UITableViewDataSource Methods

extension LoginViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.groupIdentifier ?? String()

        if identifier == FieldCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: FieldCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: FieldCellIdentifier)
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

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension LoginViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

}

// MARK: - UITextFieldDelegate Methods

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
