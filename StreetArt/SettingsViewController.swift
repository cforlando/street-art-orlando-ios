//
//  SettingsViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/28/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    struct GroupIdentifier {
        static let cell = "Cell"
        static let button = "ButtonCell"
        static let web = "WebCell"
    }

    struct Identifier {
        static let login = "login"
        static let register = "register"
        static let submit = "submit"
        static let mySubmissions = "my_submissions"
        static let updatePassword = "update_password"
        static let terms = "terms"
        static let privacy = "privacy"
        static let community = "community"
        static let logout = "logout"
    }

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

        if ApiClient.shared.isAuthenticated {
            content = ContentRow(text: SETTINGS_LOGOUT_BUTTON_TEXT)
            content.groupIdentifier = GroupIdentifier.button
            content.identifier = Identifier.logout

            rows.append(content)

            content = ContentRow(text: SETTINGS_UPDATE_PASSWORD_TEXT)
            content.groupIdentifier = GroupIdentifier.cell
            content.identifier = Identifier.updatePassword

            rows.append(content)

            sections.append(ContentSection(title: nil, rows: rows))
        } else {
            content = ContentRow(text: SETTINGS_LOGIN_BUTTON_TEXT)
            content.groupIdentifier = GroupIdentifier.button
            content.identifier = Identifier.login

            rows.append(content)

            content = ContentRow(text: SETTINGS_REGISTRATION_BUTTON_TEXT)
            content.groupIdentifier = GroupIdentifier.button
            content.identifier = Identifier.register

            rows.append(content)

            var section = ContentSection(title: nil, rows: rows)
            section.footer = SETTINGS_REGISTRATION_FOOTER_TEXT

            sections.append(section)
        }

        rows = ContentRowArray()

        content = ContentRow(text: SETTINGS_SUBMIT_ART_BUTTON_TEXT)
        content.groupIdentifier = GroupIdentifier.button
        content.identifier = Identifier.submit

        rows.append(content)

        content = ContentRow(text: SETTINGS_MY_SUBMISSIONS_TEXT)
        content.groupIdentifier = GroupIdentifier.cell
        content.identifier = Identifier.mySubmissions

        rows.append(content)
        sections.append(ContentSection(title: SETTINGS_SUBMISSIONS_TITLE_TEXT, rows: rows))

        // Information

        rows = ContentRowArray()

        content = ContentRow(text: SETTINGS_TERMS_TEXT)
        content.groupIdentifier = GroupIdentifier.web
        content.identifier = Identifier.terms

        rows.append(content)

        content = ContentRow(text: SETTINGS_PRIVACY_TEXT)
        content.groupIdentifier = GroupIdentifier.web
        content.identifier = Identifier.privacy

        rows.append(content)

        content = ContentRow(text: SETTINGS_COMMUNITY_TEXT)
        content.groupIdentifier = GroupIdentifier.web
        content.identifier = Identifier.community

        rows.append(content)

        let (version, build) = systemVersionAndBuild()
        let footerStr = "\(APP_NAME) \(version) (\(build))"

        var infoSection = ContentSection(title: nil, rows: rows)
        infoSection.footer = footerStr

        sections.append(infoSection)


        dataSource = sections
        tableView.reloadData()
    }

    func logout() {
        let actionSheet = UIAlertController(title: SETTINGS_LOGOUT_CONFIRMATION_TEXT, message: nil, preferredStyle: .actionSheet)

        let logoutAction = UIAlertAction(title: SETTINGS_LOGOUT_BUTTON_TEXT, style: .destructive) { [unowned self] (action) in
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
            ApiClient.shared.logout()
            self.updateDataSource()
        }

        actionSheet.addAction(logoutAction)

        let cancelAction = UIAlertAction(title: CANCEL_TEXT, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        self.navigationController?.present(actionSheet, animated: true, completion: nil)
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

        if identifier == GroupIdentifier.cell {
            var cell = tableView.dequeueReusableCell(withIdentifier: GroupIdentifier.cell)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: GroupIdentifier.cell)
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

        if identifier == GroupIdentifier.button {
            var cell = tableView.dequeueReusableCell(withIdentifier: GroupIdentifier.button)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: GroupIdentifier.button)
                cell?.textLabel?.textColor = Color.highlight
                cell?.textLabel?.textAlignment = .center
            }

            cell?.textLabel?.text = row.text

            cell?.selectionStyle = .default
            cell?.accessoryType = .none

            return cell!
        }

        if identifier == GroupIdentifier.web {
            var cell = tableView.dequeueReusableCell(withIdentifier: GroupIdentifier.web)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: GroupIdentifier.web)
            }

            cell?.textLabel?.text = row.text

            cell?.selectionStyle = .default
            cell?.accessoryType = .disclosureIndicator

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
        case Identifier.login:
            let controller = LoginViewController()

            controller.loginBlock = { [weak self] in
                guard let _ = self else {
                    return
                }

                self?.updateDataSource()
            }

            let navController = UINavigationController(rootViewController: controller)
            self.navigationController?.present(navController, animated: true, completion: nil)
        case Identifier.register:
            let controller = RegisterViewController()

            controller.loginBlock = { [weak self] in
                guard let _ = self else {
                    return
                }

                self?.updateDataSource()
            }

            LocalAnalytics.shared.customEvent(.registrationStart)

            let navController = UINavigationController(rootViewController: controller)
            self.navigationController?.present(navController, animated: true, completion: nil)
        case Identifier.submit:
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

            LocalAnalytics.shared.customEvent(.submissionStart)

            let navController = UINavigationController(rootViewController: controller)
            self.navigationController?.present(navController, animated: true, completion: nil)
        case Identifier.mySubmissions:
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

            let controller = SubmissionsViewController()
            controller.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(controller, animated: true)
        case Identifier.updatePassword:
            let controller = PasswordViewController()
            controller.logoutBlock = { [weak self] in
                self?.logout()
                self?.navigationController?.popViewController(animated: true)
            }

            controller.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(controller, animated: true)
        case Identifier.terms:
            let controller = WebViewController(url: URL(string: WebsiteURL.terms)!)
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        case Identifier.privacy:
            let controller = WebViewController(url: URL(string: WebsiteURL.privacy)!)
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        case Identifier.community:
            let controller = WebViewController(url: URL(string: WebsiteURL.community)!)
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        case Identifier.logout:
            logout()
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

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let _ = dataSource[section].footer, let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textAlignment = .center
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource[section].footer
    }

}

