//
//  PhotoCell.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/7/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

protocol PhotoCellDelegate: class {

    var enableImageReset: Bool { get }
    func resetImage(photoCell: PhotoCell)

}

class PhotoCell: UITableViewCell {

    enum Placeholder {
        case camera, frame
    }

    struct Constants {
        static let height: CGFloat = Defaults.defaultImageHeight
    }

    var placeholder = Placeholder.camera
    var photoImageView: UIImageView!

    var resetButton: UIButton?

    var overlayView: UIView!

    weak var delegate: PhotoCellDelegate?

    init(placeholder: Placeholder, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.accessoryType = .none

        self.placeholder = placeholder

        overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.alpha = 0

        self.contentView.addSubview(overlayView)

        photoImageView = UIImageView()
        photoImageView.contentMode = .center
        photoImageView.clipsToBounds = true
        photoImageView.image = placeholderImage

        self.contentView.addSubview(photoImageView)

        // Auto Layout

        overlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        photoImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            self.contentView.bringSubviewToFront(overlayView)
            overlayView.alpha = 1.0
        } else {
            self.contentView.sendSubviewToBack(overlayView)
            overlayView.alpha = 0.0
        }
    }

}

// MARK: - Methods

extension PhotoCell {

    func enableResetIfNeeded() {
        if let _ = resetButton {
            return
        }

        guard let delegate = self.delegate else {
            return
        }

        if delegate.enableImageReset {
            self.selectionStyle = .default

            resetButton = UIButton(type: .custom)
            resetButton?.setBackgroundImage(#imageLiteral(resourceName: "trash_icon").tintedImage(color: UIColor.red.withAlphaComponent(0.5)), for: .normal)

            resetButton?.layer.shadowColor = UIColor.black.cgColor
            resetButton?.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            resetButton?.layer.shadowOpacity = 0.7
            resetButton?.layer.shadowRadius = 1.0

            resetButton?.addTarget(self, action: #selector(resetAction(_:)), for: .touchUpInside)

            resetButton?.alpha = 0.0

            self.contentView.addSubview(resetButton!)

            resetButton?.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-20.0)
                make.bottom.equalToSuperview().offset(-20.0)
            }
        }
    }

    func set(image: UIImage?) {
        if let image = image {
            resetButton?.alpha = 1.0
            photoImageView.contentMode = .scaleAspectFill

            UIView.animate(withDuration: 0.5) { [unowned self] in
                self.photoImageView.image = image
            }
        } else {
            resetButton?.alpha = 0.0
            photoImageView.contentMode = .center
            photoImageView.image = placeholderImage
        }
    }

    func set(url: URL?) {
        if let url = url {
            resetButton?.alpha = 1.0
            photoImageView.af_setImage(withURL: url, placeholderImage: nil) { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                self?.photoImageView.contentMode = .scaleAspectFill
            }
        } else {
            resetButton?.alpha = 0.0
            photoImageView.contentMode = .center
            photoImageView.image = placeholderImage
        }
    }

    var placeholderImage: UIImage {
        switch placeholder {
        case .camera:
            return type(of: self).cameraPlaceholder
        case .frame:
            return type(of: self).framePlaceholder
        }
    }

    class var cameraPlaceholder: UIImage {
        return #imageLiteral(resourceName: "camera_icon").tintedImage(color: Color.highlight.withAlphaComponent(0.75))!
    }

    class var framePlaceholder: UIImage {
        return #imageLiteral(resourceName: "frame_icon").tintedImage(color: Color.highlight.withAlphaComponent(0.75))!
    }

}

// MARK: Selector Methods

extension PhotoCell {

    @objc func resetAction(_ sender: AnyObject?) {
        guard let delegate = self.delegate else {
            return
        }

        delegate.resetImage(photoCell: self)
    }

}
