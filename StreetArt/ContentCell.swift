//
//  ContentCell.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import SnapKit
import AlamofireImage

class ContentCell: UICollectionViewCell {

    struct Constants {
        static let height: CGFloat = Defaults.defaultImageHeight
    }

    var imageView: UIImageView!
    var textView: UIView!
    var textLabel: UILabel!

    var overlayView: UIView!

    var submission: Submission?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.masksToBounds = true

        overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.alpha = 0

        self.contentView.addSubview(overlayView)

        imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        self.contentView.addSubview(imageView)

        textView = UIView()
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        self.contentView.addSubview(textView)

        textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 14.0)
        textLabel.textColor = .white
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .center

        textView.addSubview(textLabel)

        // AutoLayout

        overlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        textView.snp.makeConstraints { (make) in
            make.height.equalTo(44.0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5.0)
            make.right.equalToSuperview().offset(-5.0)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var isHighlighted: Bool {
        willSet(newValue) {
            if newValue {
                self.contentView.bringSubviewToFront(overlayView)
                overlayView.alpha = 1.0
            } else {
                self.contentView.sendSubviewToBack(overlayView)
                overlayView.alpha = 0.0
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        textLabel.text = nil
    }

}

// MARK: - Methods

extension ContentCell {

    func set(submission: Submission?, isFavorite: Bool = false) {
        self.submission = submission

        if let url = submission?.thumbURL {
            imageView.af_setImage(withURL: url)
        } else {
            imageView.image = nil
        }

        if let text = submission?.title {
            textView.isHidden = false
            textLabel.text = text
        } else {
            textView.isHidden = true
            textLabel.text = nil
        }
    }

}
