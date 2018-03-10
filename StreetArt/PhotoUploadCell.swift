//
//  PhotoUploadCell.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/7/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class PhotoUploadCell: UITableViewCell {

    struct Constants {
        static let height: CGFloat = 250.0
    }

    var photoImageView: UIImageView!

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        photoImageView = UIImageView()
        photoImageView.backgroundColor = .lightGray
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true

        self.contentView.addSubview(photoImageView)

        photoImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: - Methods

extension PhotoUploadCell {

    func set(image: UIImage?) {
        photoImageView.image = image
    }

}
