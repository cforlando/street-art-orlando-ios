//
//  SubmissionsViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/30/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class SubmissionsViewController: UIViewController {

    struct GroupIdentifier {
        static let cell = "CellIdentifier"
        static let empty = "EmptyCell"
    }

    var tableView: UITableView!

    var refreshControl: UIRefreshControl!

    var submissions = SubmissionArray()
    var dataSource = ContentSectionArray()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = SUBMISSIONS_TITLE
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)

        tableView.refreshControl = refreshControl
        tableView.rowHeight = SubmissionCell.Constants.height

        // Auto Layout

        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        reloadSubmissions(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: Methods

extension SubmissionsViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        if submissions.isEmpty {
            content = ContentRow(text: SUBMISSIONS_EMPTY_TEXT)
            content.groupIdentifier = GroupIdentifier.empty

            rows.append(content)
        } else {
            for submission in submissions {
                content = ContentRow(object: submission)
                content.groupIdentifier = GroupIdentifier.cell
                content.height = SubmissionCell.Constants.height

                rows.append(content)
            }
        }

        sections.append(ContentSection(title: nil, rows: rows))

        dataSource = sections
        tableView.reloadData()
    }

    func reloadSubmissions(animated: Bool = false) {

        if animated {
            HUD.show(.progress, onView: self.view)
        }

        ApiClient.shared.mySubmissions { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }

            if animated {
                HUD.hide()
            }

            if weakSelf.refreshControl.isRefreshing {
                weakSelf.refreshControl.endRefreshing()
            }

            switch result {
            case .success(let submissions):
                DataManager.shared.fetchUser(completionHandler: nil)
                weakSelf.submissions = submissions
                weakSelf.updateDataSource()
            case .failure(let error):
                dLog("submissions failed: \(error)")
            }
        }
    }

}

// MARK: Selector Methods

extension SubmissionsViewController {

    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        reloadSubmissions()
    }

}

// MARK: - UITableViewDataSource Methods

extension SubmissionsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.groupIdentifier ?? String()

        if identifier == GroupIdentifier.empty {
            var cell = tableView.dequeueReusableCell(withIdentifier: GroupIdentifier.empty)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: GroupIdentifier.empty)
                cell?.textLabel?.textAlignment = .center
            }

            cell?.textLabel?.text = row.text

            return cell!
        }


        if identifier == GroupIdentifier.cell {
            var cell = tableView.dequeueReusableCell(withIdentifier: GroupIdentifier.cell) as? SubmissionCell
            if cell == nil {
                cell = SubmissionCell(reuseIdentifier: GroupIdentifier.cell)
            }

            cell?.set(submission: row.object as? Submission)

            cell?.selectionStyle = .none

            return cell!
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension SubmissionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

}

