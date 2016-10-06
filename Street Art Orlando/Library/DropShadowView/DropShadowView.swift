//
//  DropShadowView.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/5/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

@IBDesignable
class DropShadowView: UIView {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [
            UIColor.init(white: 0.5, alpha: 0.5).cgColor,
            UIColor.init(white: 0.5, alpha: 0.0).cgColor
        ]
    }
}
