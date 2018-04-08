//
//  PhotoViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/10/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import SnapKit
import MapKit

class PhotoViewController: UIViewController {

    struct Constants {
        static let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }

    let CellIdentifier = "Cell"
    let PhotoCellIdentifier = "PhotoCell"
    let MapCellIdentifier = "MapCell"

    var tableView: UITableView!
    var mapCell: MapCell?

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

        if let coordinate = submission.coordinate, let annotation = submission.annotation {
            mapCell = MapCell(reuseIdentifier: nil)

            let region = MKCoordinateRegion(center: coordinate, span: Constants.mapSpan)
            mapCell?.mapView.setRegion(region, animated: false)
            mapCell?.mapView.addAnnotation(annotation)
        }

        // Auto Layout

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

        content = ContentRow(object: submission.photoURL)
        content.groupIdentifier = PhotoCellIdentifier
        content.height = PhotoCell.Constants.height

        rows.append(content)

        var photoFooter: String?
        if let artist = submission.artist {
            photoFooter = BY_TEXT + " " + artist
        }

        var photoSection = ContentSection(title: submission.title, rows: rows)
        photoSection.footer = photoFooter

        sections.append(photoSection)

        if let _ = mapCell {
            rows = ContentRowArray()

            content = ContentRow(text: PHOTO_ART_LOCATION_TEXT)
            content.groupIdentifier = CellIdentifier

            rows.append(content)

            content = ContentRow(object: nil)
            content.groupIdentifier = MapCellIdentifier
            content.height = MapCell.Constants.height

            rows.append(content)
            sections.append(ContentSection(title: nil, rows: rows))
        }

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
            }

            cell?.textLabel?.text = row.text

            cell?.accessoryType = .none
            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == PhotoCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: PhotoCellIdentifier) as? PhotoCell
            if cell == nil {
                cell = PhotoCell(placeholder: .frame, reuseIdentifier: PhotoCellIdentifier)
            }

            cell?.set(url: row.object as? URL)

            return cell!
        }

        if identifier == MapCellIdentifier {
            return mapCell!
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension PhotoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource[section].footer
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

}
