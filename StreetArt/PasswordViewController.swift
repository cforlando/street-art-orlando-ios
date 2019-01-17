//
//  PasswordViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 5/29/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class PasswordViewController: UITableViewController {

    struct GroupIdentifier {
        static let field = "FieldCell"
    }

    var passwordField: UITextField!
    var showPasswordButton: UIButton!

    var dataSource = ContentSectionArray()

    var logoutBlock: (() -> Void)?

    lazy var emptySet: CharacterSet = {
        return CharacterSet.whitespacesAndNewlines
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = UPDATE_PASSWORD_TITLE
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.tableView = UITableView(frame: .zero, style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.keyboardDismissMode = .interactive

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: UPDATE_TEXT,
            style: .done,
            target: self,
            action: #selector(updateAction(_:))
        )

        passwordField = UITextField()
        passwordField.contentVerticalAlignment = .center
        passwordField.keyboardType = .asciiCapable
        passwordField.returnKeyType = .done
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.isSecureTextEntry = true
        passwordField.placeholder = UPDATE_PASSWORD_PLACEHOLDER

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

extension PasswordViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        content = ContentRow(object: passwordField)
        content.groupIdentifier = GroupIdentifier.field

        rows.append(content)
        sections.append(ContentSection(title: nil, rows: rows))

        dataSource = sections
        self.tableView.reloadData()
    }

}

// MARK: Selector Methods

extension PasswordViewController {

    @objc func showPasswordAction(_ sender: AnyObject?) {
        let text = passwordField.text
        passwordField.text = nil

        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
        passwordField.text = text

        if passwordField.isSecureTextEntry {
            showPasswordButton.setTitle(SHOW_PASSWORD_TEXT, for: .normal)
        } else {
            showPasswordButton.setTitle(HIDE_PASSWORD_TEXT, for: .normal)
        }
    }

    @objc func updateAction(_ sender: AnyObject?) {
        self.view.endEditing(true)

        let password = (passwordField.text ?? String()).trimmingCharacters(in: emptySet)

        if password.isEmpty {
            let alertView = UIAlertController(
                title: UPDATE_PASSWORD_ALERT_TITLE,
                message: UPDATE_PASSWORD_REQUIRED_MESSAGE,
                preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(okAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
            return
        }

        HUD.show(.progress, onView: self.view)

        ApiClient.shared.passwordUpdate(password: password) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            HUD.hide()

            switch result {
            case .success:
                let alertView = UIAlertController(
                    title: UPDATE_PASSWORD_ALERT_TITLE,
                    message: UPDATE_PASSWORD_UPDATED_MESSAGE,
                    preferredStyle: .alert
                )

                let doneAction = UIAlertAction(title: OK_TEXT, style: .cancel) { (action) in
                    self?.logoutBlock?()
                }

                alertView.addAction(doneAction)

                self?.navigationController?.present(alertView, animated: true, completion: nil)
            case .failure(let error):
                let alertView = UIAlertController(
                    title: UPDATE_PASSWORD_ALERT_TITLE,
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )

                let doneAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertView.addAction(doneAction)

                self?.navigationController?.present(alertView, animated: true, completion: nil)
            }
        }
    }

}

// MARK: - UITableViewDataSource Methods

extension PasswordViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension PasswordViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
