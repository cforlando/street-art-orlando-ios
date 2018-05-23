//
//  RegisterViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/28/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    let FieldCellIdentifier = "FieldCell"

    var tableView: UITableView!

    var dataSource = ContentSectionArray()

    var emailField: UITextField!
    var emailConfirmationField: UITextField!
    var nameField: UITextField!
    var passwordField: UITextField!

    var showPasswordButton: UIButton!

    var registerButton: UIButton!

    var footerView: UIView!

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

        nameField = UITextField()
        nameField.contentVerticalAlignment = .center
        nameField.keyboardType = .default
        nameField.returnKeyType = .done
        nameField.autocapitalizationType = .words
        nameField.autocorrectionType = .no
        nameField.placeholder = REGISTER_NAME_PLACEHOLDER
        nameField.delegate = self

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

}

// MARK: -
// MARK: Methods

extension RegisterViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        content = ContentRow(object: emailField)
        content.groupIdentifier = FieldCellIdentifier

        rows.append(content)

        content = ContentRow(object: emailConfirmationField)
        content.groupIdentifier = FieldCellIdentifier

        rows.append(content)

        content = ContentRow(object: nameField)
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

extension RegisterViewController {

    @objc func registerAction(_ sender: AnyObject?) {

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

extension RegisterViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

}

// MARK: UITextFieldDelegate Methods

extension RegisterViewController: UITextFieldDelegate {


}
