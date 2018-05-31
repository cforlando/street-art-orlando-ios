//
//  PhotoViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/10/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD
import SnapKit
import MapKit

class PhotoViewController: UIViewController {

    let PhotoCellIdentifier = "PhotoCell"
    let TitleCellIdentifier = "TitleCell"
    let ArtistCellIdentifier = "ArtistCell"
    let MapCellIdentifier = "MapCell"
    let NoteCellIdentifier = "NoteCell"
    let RemoveFavoriteCellIdentifier = "RemoveFavoriteCell"

    var tableView: UITableView!
    var mapCell: MapCell?
    var imageView: UIImageView!

    var submission: Submission!
    var dataSource = ContentSectionArray()

    var inFavorites = false

    init(submission: Submission, inFavorites: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.title = PHOTO_TITLE
        self.submission = submission
        self.inFavorites = inFavorites
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

        if ApiClient.shared.isAuthenticated {
            if submission.favorite {
                setUnfavoriteButton()
            } else {
                setFavoriteButton()
            }
        }

        if let coordinate = submission.coordinate, let annotation = submission.annotation {
            mapCell = MapCell(reuseIdentifier: nil)

            let region = MKCoordinateRegion(center: coordinate, span: Defaults.mapSpan)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

        if let title = submission.title {
            content = ContentRow(text: title)
            content.groupIdentifier = TitleCellIdentifier

            rows.append(content)
        }

        if let artist = submission.artist {
            content = ContentRow(text: BY_TEXT + " " + artist)
            content.groupIdentifier = ArtistCellIdentifier

            rows.append(content)
        }

        sections.append(ContentSection(title: PHOTO_ART_PHOTO_TEXT, rows: rows))

        rows = ContentRowArray()

        if let _ = mapCell {
            content = ContentRow(object: nil)
            content.groupIdentifier = MapCellIdentifier
            content.height = MapCell.Constants.height

            rows.append(content)
        }

        if let note = submission.locationNote {
            content = ContentRow(text: note)
            content.groupIdentifier = NoteCellIdentifier

            rows.append(content)
        }

        if !rows.isEmpty {
            sections.append(ContentSection(title: PHOTO_ART_LOCATION_TEXT, rows: rows))
        }

        if inFavorites {
            rows = ContentRowArray()

            content = ContentRow(text: REMOVE_FAVORITE_TEXT)
            content.groupIdentifier = RemoveFavoriteCellIdentifier
            content.identifier = RemoveFavoriteCellIdentifier

            rows.append(content)
            sections.append(ContentSection(title: nil, rows: rows))
        }

        dataSource = sections
        tableView.reloadData()
    }

    func setFavoriteButton() {
        guard !inFavorites else {
            return
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "heart_icon").tintedImage(color: Color.highlight),
            style: .plain,
            target: self,
            action: #selector(favoriteAction(_:))
        )
    }

    func setUnfavoriteButton() {
        guard !inFavorites else {
            return
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "heart_selected_icon").tintedImage(color: Color.highlight),
            style: .plain,
            target: self,
            action: #selector(unfavoriteAction(_:))
        )
    }

    var noteCell: UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: NoteCellIdentifier)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13.0)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .lightGray

        return cell
    }

}

// MARK: Selector Methods

extension PhotoViewController {

    @objc func favoriteAction(_ sender: AnyObject?) {
        HUD.show(.progress, onView: self.view)
        ApiClient.shared.favorite(submission: submission) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            HUD.hide()

            switch result {
            case .success:
                self?.submission.favorite = true
                self?.setUnfavoriteButton()

                if let submission = self?.submission {
                    let userInfo: [AnyHashable: Any] = [ Keys.favorite: submission, Keys.addFavorite: true ]
                    NotificationCenter.default.post(name: .favoriteUpdated, object: nil, userInfo: userInfo)
                }
            case .failure:
                let alertView = UIAlertController(
                    title: MAIN_FAVORITE_ALERT_TITLE,
                    message: MAIN_FAVORITE_ALERT_MESSAGE,
                    preferredStyle: .alert
                )

                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertView.addAction(okAction)

                self?.navigationController?.present(alertView, animated: true, completion: nil)
            }
        }
    }

    @objc func unfavoriteAction(_ sender: AnyObject?) {
        HUD.show(.progress, onView: self.view)
        ApiClient.shared.unfavorite(submission: submission) { [weak self] (result) in
            guard let _ = self else {
                return
            }

            HUD.hide()

            switch result {
            case .success:
                self?.submission.favorite = false
                self?.setFavoriteButton()

                if let submission = self?.submission {
                    let userInfo: [AnyHashable: Any] = [ Keys.favorite: submission, Keys.removeFavorite: true ]
                    NotificationCenter.default.post(name: .favoriteUpdated, object: nil, userInfo: userInfo)
                }

                if let inFavorites = self?.inFavorites, inFavorites {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure:
                let alertView = UIAlertController(
                    title: MAIN_FAVORITE_ALERT_TITLE,
                    message: MAIN_UNFAVORITE_ALERT_MESSAGE,
                    preferredStyle: .alert
                )

                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertView.addAction(okAction)

                self?.navigationController?.present(alertView, animated: true, completion: nil)
            }
        }
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

        if identifier == PhotoCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: PhotoCellIdentifier) as? PhotoCell
            if cell == nil {
                cell = PhotoCell(placeholder: .frame, reuseIdentifier: PhotoCellIdentifier)
            }

            cell?.set(url: row.object as? URL)

            return cell!
        }

        if identifier == TitleCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: TitleCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: TitleCellIdentifier)
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.textLabel?.textColor = .darkGray
            }

            cell?.textLabel?.text = row.text

            cell?.accessoryType = .none
            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == ArtistCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: ArtistCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: ArtistCellIdentifier)
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.textLabel?.textColor = .lightGray
            }

            cell?.textLabel?.text = row.text

            cell?.accessoryType = .none
            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == MapCellIdentifier {
            return mapCell!
        }

        if identifier == NoteCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: NoteCellIdentifier)
            if cell == nil {
                cell = noteCell
            }

            cell?.textLabel?.text = row.text

            cell?.accessoryType = .none
            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == RemoveFavoriteCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: RemoveFavoriteCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: RemoveFavoriteCellIdentifier)
                cell?.textLabel?.textColor = .red
                cell?.textLabel?.textAlignment = .center
            }

            cell?.textLabel?.text = row.text

            cell?.accessoryType = .none
            cell?.selectionStyle = .default

            return cell!
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension PhotoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier ?? String()

        switch identifier {
        case RemoveFavoriteCellIdentifier:
            unfavoriteAction(nil)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource[section].footer
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.groupIdentifier ?? String()

        if identifier == NoteCellIdentifier {
            let cell = noteCell
            cell.textLabel?.text = row.text

            let contentWidth = tableView.frame.width - (cell.layoutMargins.left + cell.layoutMargins.right)
            let height = cell.textLabel?.sizeThatFits(CGSize(width: contentWidth, height: 999.0)).height ?? 0.0

            return max(height + 20.0, 44.0)
        }

        return row.height ?? 44.0
    }

}
