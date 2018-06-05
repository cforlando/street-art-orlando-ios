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
import Alamofire
import AlamofireImage
import MessageUI

class PhotoViewController: UIViewController {

    let PhotoCellIdentifier = "PhotoCell"
    let DescriptionCellIdentifier = "DescriptionCell"
    let TitleCellIdentifier = "TitleCell"
    let ArtistCellIdentifier = "ArtistCell"
    let MapCellIdentifier = "MapCell"
    let NoteCellIdentifier = "NoteCell"

    var tableView: UITableView!
    var mapCell: MapCell?
    var imageView: UIImageView!

    var toolBar: UIToolbar!

    var image: UIImage?
    var imageDownloader = ImageDownloader()
    var submission: Submission!
    var dataSource = ContentSectionArray()

    var inFavorites = false

    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?

    var shouldSetupLayout = true

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

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInsetAdjustmentBehavior = .never

        if ApiClient.shared.isAuthenticated {
            if submission.favorite {
                setUnfavoriteButton()
            } else {
                setFavoriteButton()
            }
        }

        toolBar = UIToolbar(frame: .zero)
        self.view.addSubview(toolBar)

        updateToolbarItems()

        if let coordinate = submission.coordinate, let annotation = submission.annotation {
            mapCell = MapCell(reuseIdentifier: nil)

            let region = MKCoordinateRegion(center: coordinate, span: Defaults.mapSpan)
            mapCell?.mapView.setRegion(region, animated: false)
            mapCell?.mapView.addAnnotation(annotation)
        }

        // Auto Layout

        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        toolBar.snp.makeConstraints { (make) in
            make.height.equalTo(44.0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin)
        }

        updateDataSource()

        if let imageURL = submission.photoURL {
            HUD.show(.progress, onView: self.view)
            imageDownloader.download(URLRequest(url: imageURL)) { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                HUD.hide()

                if let image = response.result.value {
                    self?.image = image
                    self?.updateDataSource()
                }
            }
        }

        locationManager = CLLocationManager()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if shouldSetupLayout {
            var tableInset = tableView.contentInset
            tableInset.top = self.view.safeAreaInsets.top
            tableInset.bottom = 44.0 + self.view.safeAreaInsets.bottom

            self.tableView.contentInset = tableInset
            self.tableView.scrollIndicatorInsets = tableInset

            shouldSetupLayout = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dLog("view did appear")

        if self.isBeingPresented || self.isMovingToParentViewController {
            dLog("assign location delegate")
            locationManager.delegate = self
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dLog("view will dissapear")

        if self.isBeingDismissed || self.isMovingFromParentViewController {
            dLog("nil location delegate")
            locationManager.delegate = nil
            currentLocation = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: Methods

extension PhotoViewController {

    var noteCell: UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: NoteCellIdentifier)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13.0)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = Color.text

        return cell
    }

    var descriptionCell: UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: DescriptionCellIdentifier)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13.0)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = Color.text

        return cell
    }

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        content = ContentRow(object: image)
        content.identifier = PhotoCellIdentifier
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

        if let description = submission.description {
            rows = ContentRowArray()

            content = ContentRow(text: description)
            content.groupIdentifier = DescriptionCellIdentifier

            rows.append(content)

            sections.append(ContentSection(title: PHOTO_ART_DESCRIPTION_TEXT, rows: rows))
        }

        rows = ContentRowArray()

        if let _ = mapCell {
            content = ContentRow(object: nil)
            content.identifier = MapCellIdentifier
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

    func updateToolbarItems() {
        var itemArray = [UIBarButtonItem]()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let actionsItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionsAction(_:)))

        if inFavorites {
            let deleteItem = UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(unfavoriteConfirmationAction(_:))
            )
            itemArray = [ deleteItem, flexibleItem, actionsItem ]
        } else {
            itemArray = [ flexibleItem, actionsItem ]
        }

        toolBar.setItems(itemArray, animated: false)
    }

    func openDirections() {
        dLog("location status: \(CLLocationManager.authorizationStatus())")

        if let location = currentLocation {
            openMaps(from: location.coordinate)
            return
        }

        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            let alertView = UIAlertController(
                title: LOCATION_ERROR_ALERT_TITLE,
                message: LOCATION_ERROR_ALERT_MESSAGE,
                preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(okAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
        case .authorizedWhenInUse:
            dLog("start updating location")
            locationManager.startUpdatingLocation()
        case .notDetermined:
            dLog("request when in use authorization")
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func displaySharingOptions() {
        guard let image = self.image else {
            let alertView = UIAlertController(title: SHARE_TEXT, message: SHARE_IMAGE_NOT_AVAILABLE_TEXT, preferredStyle: .alert)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(okAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
            return
        }

        let imageData = UIImageJPEGRepresentation(image, 1.0)

        do {
            let imagePath = path(inTemporaryDirectory: uniqueIdentifier() + ".jpg")
            let imageURL = URL(fileURLWithPath: imagePath)
            try imageData?.write(to: imageURL)

            var message = SHARE_IMAGE_MESSAGE

            var messageLines = [String]()
            if let title = submission.title {
                messageLines.append(PHOTO_TITLE_TEXT + ": " + title)
            }

            if let artist = submission.artist {
                messageLines.append(PHOTO_ARTIST_TEXT + ": " + artist)
            }

            if !messageLines.isEmpty {
                message += "\n\n"
                message += messageLines.joined(separator: "\n")
            }

            let activityController = UIActivityViewController(activityItems: [message, imageURL], applicationActivities: nil)

            self.navigationController?.present(activityController, animated: true, completion: nil)
        } catch {

        }
    }

    func displayCorrectionEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            let alertView = UIAlertController(title: CORRECTION_TEXT, message: EMAIL_NOT_CONFIGURED_TEXT, preferredStyle: .alert)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(okAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
            return
        }

        var emailBody = EMAIL_CORRECTION_BODY
        emailBody += "ID: \(submission.id)"

        if let submissionTitle = submission.title {
            emailBody += "TITLE: \(submissionTitle)"
        }

        if let submissionArtist = submission.artist {
            emailBody += "ARTIST: \(submissionArtist)"
        }

        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([Emails.correction])
        controller.setSubject(EMAIL_CORRECTION_SUBJECT)
        controller.setMessageBody(emailBody, isHTML: false)

        self.present(controller, animated: true, completion: nil)
    }

    func displayReportEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            let alertView = UIAlertController(title: REPORT_TEXT, message: EMAIL_NOT_CONFIGURED_TEXT, preferredStyle: .alert)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(okAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
            return
        }

        var emailBody = EMAIL_REPORT_BODY
        emailBody += "ID: \(submission.id)"

        if let submissionTitle = submission.title {
            emailBody += "TITLE: \(submissionTitle)"
        }

        if let submissionArtist = submission.artist {
            emailBody += "ARTIST: \(submissionArtist)"
        }

        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([Emails.report])
        controller.setSubject(EMAIL_REPORT_SUBJECT)
        controller.setMessageBody(emailBody, isHTML: false)

        self.present(controller, animated: true, completion: nil)
    }

    func openMaps(from: CLLocationCoordinate2D) {
        guard let to = submission.coordinate else {
            return
        }

        var launchOptions = [String: Any]()
        launchOptions[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving

        let fromPlacemark = MKPlacemark(coordinate: from, addressDictionary: nil)
        let fromLocation = MKMapItem(placemark: fromPlacemark)
        fromLocation.name = CURRENT_LOCATION_TEXT

        let toPlacemark = MKPlacemark(coordinate: to, addressDictionary: nil)
        let toLocation = MKMapItem(placemark: toPlacemark)
        toLocation.name = submission.title ?? STREET_ART_LOCATION_TEXT

        MKMapItem.openMaps(with: [fromLocation, toLocation], launchOptions: launchOptions) 
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

    @objc func unfavoriteConfirmationAction(_ sender: AnyObject?) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let removeAction = UIAlertAction(title: REMOVE_FAVORITE_TEXT, style: .destructive) { [unowned self] (action) in
            self.unfavoriteAction(nil)
        }
        actionSheet.addAction(removeAction)

        let cancelAction = UIAlertAction(title: CANCEL_TEXT, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        self.navigationController?.present(actionSheet, animated: true, completion: nil)
    }

    @objc func actionsAction(_ sender: AnyObject?) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let shareAction = UIAlertAction(title: SHARE_TEXT, style: .default) { [unowned self] (action) in
            self.displaySharingOptions()
        }
        actionSheet.addAction(shareAction)

        let directionsAction = UIAlertAction(title: DIRECTIONS_TEXT, style: .default) { [unowned self] (action) in
            self.openDirections()
        }
        actionSheet.addAction(directionsAction)

        let correctionAction = UIAlertAction(title: CORRECTION_TEXT, style: .default) { [unowned self] (action) in
            self.displayCorrectionEmail()
        }
        actionSheet.addAction(correctionAction)

        let reportAction = UIAlertAction(title: REPORT_TEXT, style: .destructive) { [unowned self] (action) in
            self.displayReportEmail()
        }
        actionSheet.addAction(reportAction)

        let cancelAction = UIAlertAction(title: CANCEL_TEXT, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        self.navigationController?.present(actionSheet, animated: true, completion: nil)
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

            cell?.set(image: row.object as? UIImage)

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

        if identifier == DescriptionCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: DescriptionCellIdentifier)
            if cell == nil {
                cell = descriptionCell
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
        case PhotoCellIdentifier:
            let controller = ImageViewController(image: row.object as? UIImage)
            let navController = UINavigationController(rootViewController: controller)

            self.navigationController?.present(navController, animated: true, completion: nil)
        case MapCellIdentifier:
            let controller = MapViewController()
            let navController = UINavigationController(rootViewController: controller)

            self.navigationController?.present(navController, animated: true, completion: nil)
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

        if identifier == DescriptionCellIdentifier {
            let cell = descriptionCell
            cell.textLabel?.text = row.text

            let contentWidth = tableView.frame.width - (cell.layoutMargins.left + cell.layoutMargins.right)
            let height = cell.textLabel?.sizeThatFits(CGSize(width: contentWidth, height: 2000.0)).height ?? 0.0

            return max(height + 40.0, 44.0)
        }

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

// MARK: - CLLocationManagerDelegate Methods

extension PhotoViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        dLog("\(String(status.rawValue))")

        switch status {
        case .authorizedWhenInUse:
            dLog("authorized when in use")
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = currentLocation {
            return
        }

        if let location = locations.first {
            dLog("found location: \(location)")
            manager.stopUpdatingLocation()
            currentLocation = location
            openMaps(from: location.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dLog("location failed: \(error)")
    }

}

// MARK: - MFMailComposeViewControllerDelegate Methods

extension PhotoViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

