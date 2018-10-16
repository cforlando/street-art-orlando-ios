//
//  FavoriteButton.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/20/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class FavoriteButton: UIControl {

    var imageView: UIImageView!

    struct Constants {
        static let width: CGFloat = 28.0
        static let height: CGFloat = 24.0
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView(image: type(of: self).defaultImage)
        imageView.contentMode = .scaleAspectFit

        self.addSubview(imageView)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var isSelected: Bool {
        willSet(newSelected) {
            imageView.image = newSelected ? type(of: self).selectedImage : type(of: self).defaultImage
        }
    }

    override var isHighlighted: Bool {
        willSet(newHighlighted) {
            imageView.image = newHighlighted ? type(of: self).selectedImage : type(of: self).defaultImage
        }
    }

}

// MARK: - Methods

extension FavoriteButton {

    class var selectedImage: UIImage {
        return #imageLiteral(resourceName: "heart_selected_icon").tintedImage(color: .white)!
    }

    class var defaultImage: UIImage {
        return #imageLiteral(resourceName: "heart_icon").tintedImage(color: .white)!
    }

    func setupConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: Constants.width, height: Constants.height))
            make.center.equalToSuperview()
        }
    }

}
