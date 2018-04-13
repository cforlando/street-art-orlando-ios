//
//  MapDot.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/8/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class MapDot: UIView {

    struct Constants {
        static let height: CGFloat = 30.0
        static let innerHeight: CGFloat = 12.0
    }

    var innerDot: UIView!

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: Constants.height, height: Constants.height))

        self.backgroundColor = Color.highlight.withAlphaComponent(0.15)

        self.layer.cornerRadius = Constants.height / 2.0
        self.layer.borderColor = Color.highlight.cgColor
        self.layer.borderWidth = singlePixelLineMetric()

        innerDot = UIView()
        innerDot.backgroundColor = Color.highlight

        innerDot.layer.cornerRadius = Constants.innerHeight / 2.0

        self.addSubview(innerDot)

        innerDot.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: Constants.innerHeight, height: Constants.innerHeight))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
