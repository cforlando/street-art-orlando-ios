//
//  PhotoViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/10/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import SnapKit

class PhotoViewController: UIViewController {

    let CellIdentifier = "Cell"

    var tableView: UITableView!

    var submission: Submission!
    var dataSource = ContentSectionArray()

    var imageView: UIImageView!

    init(submission: Submission) {
        super.init(nibName: nil, bundle: nil)
        self.title = PHOTO_TITLE
        self.submission = submission
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white

        self.navigationItem.largeTitleDisplayMode = .never

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        if let url = submission.photoURL {
            imageView.af_setImage(withURL: url)
        }

        imageView.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: Defaults.defaultImageHeight)

        // Auto Layout

        tableView.tableHeaderView = imageView

        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        updateDataSource()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: Methods

extension PhotoViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        content = ContentRow(text: submission.title)
        content.groupIdentifier = CellIdentifier

        rows.append(content)

        sections.append(ContentSection(title: nil, rows: rows))

        dataSource = sections
        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource Methods

extension PhotoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.groupIdentifier ?? String()

        if identifier == CellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            }

            cell?.textLabel?.text = row.text

            cell?.accessoryType = .none
            cell?.selectionStyle = .none

            return cell!
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension PhotoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

}
