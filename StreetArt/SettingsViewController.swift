//
//  SettingsViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/28/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    let CellIdentifier = "Cell"
    let ButtonCellIdentifier = "ButtonCell"

    let LoginIdentifier = "login"
    let RegisterIdentifier = "register"
    let SubmitIdentifier = "submit"
    let MySubmissionsIdentifier = "my_submissions"
    let LogoutIdentifier = "logout"

    var tableView: UITableView!

    var dataSource = ContentSectionArray()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = SETTINGS_TITLE
        self.tabBarItem = UITabBarItem(title: SETTINGS_TAB, image: #imageLiteral(resourceName: "settings_tab"), tag: 2)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Auto Layout

        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        updateDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: Methods

extension SettingsViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        if !ApiClient.shared.isAuthenticated {
            content = ContentRow(text: SETTINGS_LOGIN_BUTTON_TEXT)
            content.groupIdentifier = ButtonCellIdentifier
            content.identifier = LoginIdentifier

            rows.append(content)

            content = ContentRow(text: SETTINGS_REGISTRATION_BUTTON_TEXT)
            content.groupIdentifier = ButtonCellIdentifier
            content.identifier = RegisterIdentifier

            rows.append(content)

            var section = ContentSection(title: nil, rows: rows)
            section.footer = SETTINGS_REGISTRATION_FOOTER_TEXT

            sections.append(section)
        }

        rows = ContentRowArray()

        content = ContentRow(text: SETTINGS_SUBMIT_ART_BUTTON_TEXT)
        content.groupIdentifier = ButtonCellIdentifier
        content.identifier = SubmitIdentifier

        rows.append(content)

        content = ContentRow(text: SETTINGS_MY_SUBMISSIONS_TEXT)
        content.groupIdentifier = CellIdentifier
        content.identifier = MySubmissionsIdentifier

        rows.append(content)
        sections.append(ContentSection(title: SETTINGS_SUBMISSIONS_TITLE_TEXT, rows: rows))

        if ApiClient.shared.isAuthenticated {
            rows = ContentRowArray()

            content = ContentRow(text: SETTINGS_LOGOUT_BUTTON_TEXT)
            content.groupIdentifier = ButtonCellIdentifier
            content.identifier = LogoutIdentifier

            rows.append(content)
            sections.append(ContentSection(title: nil, rows: rows))
        }

        dataSource = sections
        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource Methods

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.groupIdentifier ?? String()

        if identifier == ButtonCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: ButtonCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: ButtonCellIdentifier)
                cell?.textLabel?.textColor = Color.highlight
                cell?.textLabel?.textAlignment = .center
            }

            cell?.textLabel?.text = row.text

            cell?.selectionStyle = .default
            cell?.accessoryType = .none

            return cell!
        }

        if identifier == CellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
            }

            cell?.textLabel?.text = row.text

            if let _ = row.identifier {
                cell?.selectionStyle = .default
                cell?.accessoryType = .disclosureIndicator
            } else {
                cell?.selectionStyle = .none
                cell?.accessoryType = .none
            }

            return cell!
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier ?? String()

        switch identifier {
        case LoginIdentifier:
            let controller = LoginViewController()

            controller.loginBlock = { [weak self] in
                guard let _ = self else {
                    return
                }

                self?.updateDataSource()
            }

            let navController = UINavigationController(rootViewController: controller)

            self.navigationController?.present(navController, animated: true, completion: nil)
        case RegisterIdentifier:
            let controller = RegisterViewController()
            let navController = UINavigationController(rootViewController: controller)

            self.navigationController?.present(navController, animated: true, completion: nil)
        case SubmitIdentifier:
            guard ApiClient.shared.isAuthenticated else {
                let alertView = UIAlertController(
                    title: LOGIN_ERROR_ALERT_TITLE,
                    message: LOGIN_ERROR_SUBMIT_LOGIN_ALERT_MESSAGE,
                    preferredStyle: .alert
                )

                let doneAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertView.addAction(doneAction)

                self.navigationController?.present(alertView, animated: true, completion: nil)
                return
            }

            guard isCameraAvailable() || isPhotoLibraryAvailable() else {
                let alertView = UIAlertController(title: PHOTOS_NOT_SUPPORTED_ALERT, message: nil, preferredStyle: .alert)

                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertView.addAction(okAction)

                self.navigationController?.present(alertView, animated: true, completion: nil)
                return
            }

            let controller = AddViewController()

            controller.completionBlock = { [weak self] in
                guard let _ = self else {
                    return
                }

                self?.navigationController?.dismiss(animated: true, completion: nil)
            }

            controller.cancelBlock = { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }

            let navController = UINavigationController(rootViewController: controller)
            self.navigationController?.present(navController, animated: true, completion: nil)
        case MySubmissionsIdentifier:
            let controller = SubmissionsViewController()
            controller.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(controller, animated: true)
        case LogoutIdentifier:
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
            ApiClient.shared.logout()
            updateDataSource()
        default:
            break
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource[section].footer
    }

}

