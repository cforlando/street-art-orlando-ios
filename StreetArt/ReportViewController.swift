//
//  ReportViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 1/16/19.
//  Copyright © 2019 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class ReportViewController: UITableViewController {

    struct GroupIdentifier {
        static let cell = "Cell"
    }

    var dataSource = ContentSectionArray()

    var submission: Submission!

    var reportCodes = ReportCodeArray()
    var selectedCode: ReportCode?

    init(submission: Submission) {
        super.init(nibName: nil, bundle: nil)
        self.title = REPORT_TEXT
        self.submission = submission
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.tableView = UITableView(frame: .zero, style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: CANCEL_TEXT,
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: SUBMIT_TEXT,
            style: .done,
            target: self,
            action: #selector(submitAction(_:))
        )

        self.navigationItem.rightBarButtonItem?.isEnabled = false

        DataManager.shared.fetchReportCodes(force: false) { [weak self] (reportCodes) in
            guard let _ = self else {
                return
            }

            if reportCodes.isEmpty {
                let alertView = UIAlertController(
                    title: REPORT_TEXT,
                    message: REPORT_CODES_ERROR_TEXT,
                    preferredStyle: .alert
                )

                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertView.addAction(okAction)

                self?.navigationController?.present(alertView, animated: true, completion: nil)
            } else {
                self?.reportCodes = reportCodes
                self?.updateDataSource()
            }
        }

    }

}

// MARK: - Methods

extension ReportViewController {

    func updateDataSource() {
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedCode != nil
        self.tableView.reloadData()
    }

}

// MARK: Selector Methods

extension ReportViewController {

    @objc func submitAction(_ sender: AnyObject?) {
        let submissionId = submission.id
        let code = selectedCode?.code ?? -1
        let userId = DataManager.shared.user?.id

        HUD.show(.progress, onView: self.view)
        ApiClient.shared.submitReport(submissionId: submissionId, code: code, userId: userId) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            HUD.hide()

            switch result {
            case .success:
                let alertView = UIAlertController(
                    title: REPORT_TEXT,
                    message: REPORT_SUCCESS_TEXT,
                    preferredStyle: .alert
                )

                let doneAction = UIAlertAction(title: OK_TEXT, style: .cancel) { [weak self] (handler) in
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }

                alertView.addAction(doneAction)

                self?.navigationController?.present(alertView, animated: true, completion: nil)
            case .failure(let error):
                let alertView = UIAlertController(
                    title: REPORT_TEXT,
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )

                let doneAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertView.addAction(doneAction)

                self?.navigationController?.present(alertView, animated: true, completion: nil)
            }
        }
    }

    @objc func dismissAction(_ sender: AnyObject?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

// MARK: - UITableViewDataSource Methods

extension ReportViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportCodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: GroupIdentifier.cell)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: GroupIdentifier.cell)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        }

        let code = reportCodes[indexPath.row]

        cell?.textLabel?.text = code.text

        if let selectedCode = self.selectedCode, code == selectedCode {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }

        cell?.selectionStyle = .default

        return cell!
    }

}

// MARK: - UITableViewDelegate Methods

extension ReportViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        selectedCode = reportCodes[indexPath.row]
        updateDataSource()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return REPORT_QUESTION_TEXT
    }

}
