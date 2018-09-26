//
//  AddViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import MobileCoreServices
import MapKit
import PKHUD

class AddViewController: UIViewController {

    struct Constants {
        static let notesHeight: CGFloat = 120.0
    }

    let TitleCellIdentifier = "TitleCell"
    let ArtistCellIdentifier = "ArtistCell"
    let PhotoCellIdentifier = "PhotoCell"
    let MapCellIdentifier = "MapCell"
    let UpdateLocationCellIdentifier = "UpdateLocationCell"
    let NotesCellIdentifier = "NotesCell"

    var tableView: UITableView!

    var titleField: UITextField!
    var artistField: UITextField!
    var imageView: UIImageView!
    var notesTextView: UITextView!

    var notesIndexPath: IndexPath?

    var mapCell: MapCell!

    var dataSource = ContentSectionArray()
    var image: UIImage?

    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?

    var completionBlock: (() -> Void)?
    var cancelBlock: (() -> Void)?

    var shouldUpdateConstraints = true

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = ADD_TITLE
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .interactive

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: SUBMIT_TEXT,
            style: .done,
            target: self,
            action: #selector(saveAction(_:))
        )

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: CANCEL_TEXT,
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )

        titleField = UITextField()
        titleField.contentVerticalAlignment = .center
        titleField.keyboardType = .default
        titleField.returnKeyType = .done
        titleField.autocapitalizationType = .words
        titleField.placeholder = ADD_NAME_PLACEHOLDER

        artistField = UITextField()
        artistField.contentVerticalAlignment = .center
        artistField.keyboardType = .default
        artistField.returnKeyType = .done
        artistField.autocapitalizationType = .words
        artistField.placeholder = ADD_ARTIST_PLACEHOLDER

        notesTextView = UITextView()
        notesTextView.font = UIFont.systemFont(ofSize: 14.0)
        notesTextView.delegate = self

        mapCell = MapCell(reuseIdentifier: nil)

        let region = MKCoordinateRegion(center: Defaults.mapCoordinate, span: Defaults.mapSpan)
        mapCell.mapView.setRegion(region, animated: false)

        // AutoLayout

        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        // Setup

        locationManager = CLLocationManager()
        updateDataSource()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardShown(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardHidden(_:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        locationManager.delegate = self

        if currentLocation == nil {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

}

// MARK: - Methods

extension AddViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        // Photo Section

        content = ContentRow()
        content.identifier = PhotoCellIdentifier
        content.object = image
        content.height = PhotoCell.Constants.height

        rows.append(content)
        sections.append(ContentSection(title: PHOTO_ART_PHOTO_TEXT, rows: rows))

        // Map Section

        rows = ContentRowArray()

        content = ContentRow(object: nil)
        content.identifier = MapCellIdentifier
        content.height = MapCell.Constants.height

        rows.append(content)

        content = ContentRow(text: PHOTO_UPDATE_LOCATION_TEXT)
        content.identifier = UpdateLocationCellIdentifier

        rows.append(content)

        sections.append(ContentSection(title: PHOTO_ART_LOCATION_TEXT, rows: rows))

        // Additional Info Section

        rows = ContentRowArray()

        content = ContentRow()
        content.identifier = TitleCellIdentifier

        rows.append(content)

        content = ContentRow()
        content.identifier = ArtistCellIdentifier

        rows.append(content)

        sections.append(ContentSection(title: PHOTO_ADDITIONAL_INFORMATION_TEXT, rows: rows))

        // Notes Section

        rows = ContentRowArray()

        content = ContentRow()
        content.identifier = NotesCellIdentifier
        content.height = Constants.notesHeight

        rows.append(content)

        var notesSection = ContentSection(title: PHOTO_LOCATION_NOTES_TEXT, rows: rows)
        notesSection.footer = PHOTO_LOCATION_NOTES_FOOTER_TEXT

        sections.append(notesSection)

        notesIndexPath = IndexPath(row: rows.count - 1, section: sections.count - 1)

        dataSource = sections
        tableView.reloadData()
    }

}

// MARK: -
// MARK: Methods

extension AddViewController {

    func showCamera() {
        let imageController = UIImagePickerController()
        imageController.view.backgroundColor = .white
        imageController.delegate = self
        imageController.sourceType = .camera
        imageController.allowsEditing = false
        imageController.mediaTypes = [ kUTTypeImage as String ]

        self.navigationController?.present(imageController, animated: true, completion: nil)
    }

    func showPhotoLibrary() {
        let imageController = UIImagePickerController()
        imageController.view.backgroundColor = .white
        imageController.delegate = self
        imageController.sourceType = .photoLibrary
        imageController.allowsEditing = false
        imageController.mediaTypes = [ kUTTypeImage as String ]

        self.navigationController?.present(imageController, animated: true, completion: nil)
    }
}

// MARK: Selector Methods

extension AddViewController {

    @objc func saveAction(_ sender: AnyObject?) {
        self.view.endEditing(true)

        var errorMessages = [String]()

        let emptySet = CharacterSet.whitespacesAndNewlines

        if image == nil {
            errorMessages.append(UPLOAD_REQUIRED_IMAGE)
        }

        var artTitle: String? = (titleField.text ?? String()).trimmingCharacters(in: emptySet)
        if let stringToCompare = artTitle, stringToCompare.isEmpty {
            artTitle = nil
        }

        var artist: String? = (artistField.text ?? String()).trimmingCharacters(in: emptySet)
        if let stringToCompare = artist, stringToCompare.isEmpty {
            artist = nil
        }

        var locationNote: String? = notesTextView.text.trimmingCharacters(in: emptySet)
        if let stringToCompare = locationNote, stringToCompare.isEmpty {
            locationNote = nil
        }

        if !errorMessages.isEmpty {
            let message = errorMessages.joined(separator: "\n")
            let alertView = UIAlertController(title: UPLOAD_REQUIRED_TITLE, message: message, preferredStyle: .alert)

            let doneAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(doneAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
            return
        }

        let coordinate = currentLocation?.coordinate ?? Defaults.mapCoordinate

        let upload = SubmissionUpload(image: image!, coordinate: coordinate, title: artTitle)
        upload.artist = artist
        upload.locationNote = locationNote

        HUD.show(.progress, onView: self.view)
        ApiClient.shared.upload(submission: upload) { [weak self] (result) in
            HUD.hide()

            guard let _ = self else {
                return
            }

            if let _ = result.error {
                let alertController = UIAlertController(title: UPLOAD_ERROR_TITLE, message: UPLOAD_ERROR_MESSAGE, preferredStyle: .alert)

                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertController.addAction(okAction)

                self?.navigationController?.present(alertController, animated: true, completion: nil)
                return
            }

            LocalAnalytics.shared.customEvent(.submissionSuccess)
            self?.completionBlock?()
        }
    }

    @objc func dismissAction(_ sender: AnyObject?) {
        cancelBlock?()
    }

    @objc func keyboardShown(_ notification: NSNotification) {
        if let kbFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInset = tableView.contentInset
            contentInset.bottom = kbFrame.size.height

            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.contentInset = contentInset

                if self.notesTextView.isFirstResponder {
                    if let indexPath = self.notesIndexPath {
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                }
            })
        }
    }

    @objc func keyboardHidden(_ notification: NSNotification) {
        var contentInset = tableView.contentInset
        contentInset.bottom = 0.0

        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.contentInset = contentInset
        })
    }
}

// MARK: - UITableViewDataSource Methods

extension AddViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier ?? String()

        if identifier == PhotoCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: PhotoCellIdentifier) as? PhotoCell
            if cell == nil {
                cell = PhotoCell(placeholder: .camera, reuseIdentifier: PhotoCellIdentifier)
                cell?.delegate = self
                cell?.enableResetIfNeeded()
            }

            cell?.set(image: row.object as? UIImage)

            return cell!
        }

        if identifier == MapCellIdentifier {
            return mapCell
        }

        if identifier == UpdateLocationCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: UpdateLocationCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: UpdateLocationCellIdentifier)
                cell?.textLabel?.textColor = Color.highlight
                cell?.textLabel?.textAlignment = .center
            }

            cell?.textLabel?.text = row.text

            cell?.accessoryType = .none
            cell?.selectionStyle = .default

            return cell!
        }

        if identifier == TitleCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: TitleCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: TitleCellIdentifier)
            }

            let contentWidth = tableView.frame.size.width - (tableView.layoutMargins.right * 2.0)
            titleField.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: 40.0)

            cell?.accessoryView = titleField
            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == ArtistCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: ArtistCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: ArtistCellIdentifier)
            }

            let contentWidth = tableView.frame.size.width - (tableView.layoutMargins.right * 2.0)
            artistField.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: 40.0)

            cell?.accessoryView = artistField
            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == NotesCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: NotesCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: NotesCellIdentifier)
            }

            let contentWidth = tableView.frame.size.width - (tableView.layoutMargins.right * 2.0)
            notesTextView.frame = CGRect(x: 0.0, y: 5.0, width: contentWidth, height: Constants.notesHeight - 10.0)

            cell?.accessoryView = notesTextView
            cell?.selectionStyle = .none

            return cell!
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

}

// MARK: UITableViewDelegate Methods

extension AddViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier ?? String()

        switch identifier {
        case PhotoCellIdentifier:
            let actionSheet = UIAlertController(title: SELECT_PHOTO_ALERT_TITLE, message: nil, preferredStyle: .actionSheet)

            if isCameraAvailable() {
                let cameraAction = UIAlertAction(title: USE_CAMERA_TEXT, style: .default) { [weak self] (action) in
                    self?.showCamera()
                }
                actionSheet.addAction(cameraAction)
            }

            if isPhotoLibraryAvailable() {
                let libraryAction = UIAlertAction(title: USE_PHOTO_LIBRARY_TEXT, style: .default) { [weak self] (action) in
                    self?.showPhotoLibrary()
                }
                actionSheet.addAction(libraryAction)
            }

            let cancelAction = UIAlertAction(title: CANCEL_TEXT, style: .cancel, handler: nil)
            actionSheet.addAction(cancelAction)

            self.navigationController?.present(actionSheet, animated: true, completion: nil)
        case UpdateLocationCellIdentifier:
            let defaultLocation = CLLocation(
                latitude: Defaults.mapCoordinate.latitude,
                longitude: Defaults.mapCoordinate.longitude
            )

            let controller = MapUpdateViewController(currentLocation: currentLocation ?? defaultLocation)
            controller.title = PHOTO_ART_LOCATION_TEXT

            controller.saveBlock = { [weak self] (coordinate) in
                guard let weakSelf = self else {
                    return
                }

                weakSelf.currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

                for annotation in weakSelf.mapCell.mapView.annotations {
                    weakSelf.mapCell.mapView.removeAnnotation(annotation)
                }

                let annotation = SubmissionAnnotation(title: nil, coordinate: coordinate)
                weakSelf.mapCell.mapView.addAnnotation(annotation)

                let region = MKCoordinateRegion(center: annotation.coordinate, span: Defaults.mapSpan)
                weakSelf.mapCell.mapView.setRegion(region, animated: false)

                weakSelf.navigationController?.dismiss(animated: true, completion: nil)
            }

            controller.cancelBlock = { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }

            LocalAnalytics.shared.customEvent(.submissionUpdateLocation)

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
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

}

// MARK: - PhotoCellDelegate Methods

extension AddViewController: PhotoCellDelegate{

    var enableImageReset: Bool {
        return true
    }

    func resetImage(photoCell: PhotoCell) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let resetAction = UIAlertAction(title: ADD_RESET_PHOTO_TEXT, style: .destructive) { [unowned self] (action) in
            LocalAnalytics.shared.customEvent(.submissionResetPhoto)
            photoCell.set(image: nil)
            self.image = nil
        }
        actionSheet.addAction(resetAction)

        let cancelAction = UIAlertAction(title: CANCEL_TEXT, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        self.navigationController?.present(actionSheet, animated: true, completion: nil)
    }

}

// MARK: - UIImagePickerControllerDelegate Methods

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.image = image.cfo_scaleAndRotate(withMaxResolution: Defaults.maxImageResizeInPixels)
            updateDataSource()
        }

        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

// MARK: - CLlocationManagerDelegate Methods

extension AddViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        dLog("\(String(status.rawValue))")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = currentLocation {
            return
        }

        if let location = locations.first {
            manager.stopUpdatingLocation()
            currentLocation = location

            let region = MKCoordinateRegion(center: location.coordinate, span: Defaults.mapSpan)
            mapCell.mapView.setRegion(region, animated: true)
            mapCell.mapView.addAnnotation(SubmissionAnnotation(title: nil, coordinate: location.coordinate))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dLog("location failed: \(error)")
    }

}

// MARK: - UITextViewDelegate Methods

extension AddViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= Defaults.maxCharactersInTextView
    }

}
