//
//  AddViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddViewController: UIViewController {

    let NameCellIdentifier = "NameCell"
    let ImageCellIdentifier = "ImageCell"
    let AddImageButtonIdentifier = "AddImageButtonCell"
    let RemoveImageButtonIdentifier = "RemoveImageButtonCell"

    var tableView: UITableView!

    var nameField: UITextField!
    var imageView: UIImageView!

    var dataSource = ContentSectionArray()
    var image: UIImage?

    var saveBlock: ((StreetArt?) -> Void)?
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

        nameField = UITextField()
        nameField.contentVerticalAlignment = .center
        nameField.keyboardType = .default
        nameField.returnKeyType = .done
        nameField.autocapitalizationType = .words
        nameField.placeholder = ADD_NAME_PLACEHOLDER

        updateDataSource()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if shouldUpdateConstraints {
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }

            shouldUpdateConstraints = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - Methods

extension AddViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        // Name
        content = ContentRow()
        content.identifier = NameCellIdentifier

        rows.append(content)

        sections.append(ContentSection(title: nil, rows: rows))
        rows = ContentRowArray()

        // Buttons

        if let image = self.image {
            dLog("image found")

            content = ContentRow()
            content.identifier = ImageCellIdentifier
            content.object = image
            content.height = PhotoUploadCell.Constants.height

            rows.append(content)

            content = ContentRow(text: REMOVE_PHOTO_TEXT)
            content.identifier = RemoveImageButtonIdentifier

            rows.append(content)
        } else {
            dLog("image not found")
            content = ContentRow(text: SELECT_PHOTO_TEXT)
            content.identifier = AddImageButtonIdentifier

            rows.append(content)
        }

        sections.append(ContentSection(title: nil, rows: rows))
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
        saveBlock?(StreetArt())
    }

    @objc func dismissAction(_ sender: AnyObject?) {
        cancelBlock?()
    }

    func keyboardShown(notification: NSNotification) {
        if let kbFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInset = tableView.contentInset
            contentInset.bottom = kbFrame.size.height

            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.contentInset = contentInset
            })
        }
    }

    func keyboardHidden(notification: NSNotification) {
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

        if identifier == NameCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: NameCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: NameCellIdentifier)
            }

            let contentWidth = tableView.frame.size.width - (tableView.layoutMargins.right * 2.0)
            nameField.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: 40.0)

            cell?.accessoryView = nameField
            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == ImageCellIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: ImageCellIdentifier) as? PhotoUploadCell
            if cell == nil {
                cell = PhotoUploadCell(reuseIdentifier: ImageCellIdentifier)
            }

            cell?.set(image: row.object as? UIImage)

            cell?.accessoryType = .none
            cell?.selectionStyle = .none

            return cell!
        }

        if identifier == AddImageButtonIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: AddImageButtonIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: AddImageButtonIdentifier)
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.textColor = Color.highlight
            }

            cell?.textLabel?.text = row.text

            cell?.accessoryType = .none
            cell?.selectionStyle = .default

            return cell!
        }

        if identifier == RemoveImageButtonIdentifier {
            var cell = tableView.dequeueReusableCell(withIdentifier: RemoveImageButtonIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: RemoveImageButtonIdentifier)
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.textColor = .red
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

extension AddViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier ?? String()

        switch identifier {
        case AddImageButtonIdentifier:
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
        case RemoveImageButtonIdentifier:
            image = nil
            updateDataSource()
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }

}

// MARK: - UIImagePickerControllerDelegate Methods

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = image.cfo_scaleAndRotate(withMaxResolution: Constants.maxImageHeightInPixels)
            updateDataSource()
        }

        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}
