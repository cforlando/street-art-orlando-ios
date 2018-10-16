//
//  SubmissionCell.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/30/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class SubmissionCell: UITableViewCell {

    struct Constants {
        static let photoSize = CGSize(width: 100.0, height: 75.0)
        static let height: CGFloat = photoSize.height + 20.0
    }

    var photoView: UIImageView!
    var titleLabel: UILabel!
    var supportLabel: UILabel!
    var statusLabel: UILabel!

    init(reuseIdentifier: String) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        self.accessoryType = .none

        photoView = UIImageView()
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true

        self.contentView.addSubview(photoView)

        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13.0)
        titleLabel.textColor = Color.text
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2

        self.contentView.addSubview(titleLabel)

        supportLabel = UILabel()
        supportLabel.font = UIFont.systemFont(ofSize: 13.0)
        supportLabel.textColor = Color.support
        supportLabel.textAlignment = .left

        self.contentView.addSubview(supportLabel)

        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 15.0)
        statusLabel.textAlignment = .left

        self.contentView.addSubview(statusLabel)

        setupCosntraints()
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

extension SubmissionCell {

    func setupCosntraints() {
        photoView.snp.makeConstraints { (make) in
            make.size.equalTo(Constants.photoSize)
            make.leftMargin.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(photoView.snp.top).offset(5.0)
            make.left.equalTo(photoView.snp.right).offset(5.0)
            make.rightMargin.equalToSuperview()
        }

        supportLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5.0)
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(titleLabel.snp.right)
        }

        statusLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(photoView.snp.bottom).offset(-5.0)
            make.left.equalTo(titleLabel.snp.left)
            make.rightMargin.equalToSuperview()
        }
    }

    func set(submission: Submission?) {
        if let url = submission?.tinyURL {
            photoView.af_setImage(withURL: url)
        } else {
            photoView.image = nil
        }

        titleLabel.text = submission?.title ?? NO_TITLE_TEXT
        supportLabel.text = submission?.artist ?? NO_ARTIST_TEXT

        statusLabel.text = submission?.status.labelString
        statusLabel.textColor = submission?.status.color ?? Color.text
    }

}
