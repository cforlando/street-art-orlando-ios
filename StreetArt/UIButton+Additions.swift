//
//  UIButton+Additions.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/28/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

extension UIButton {

    class func roundedButton(backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true

        let image = UIImage.backgroundTintedImage(color: backgroundColor)
        let disabledImage = UIImage.backgroundTintedImage(color: UIColor(hexString: "DDDDDD"))
        let highlightedImage = UIImage.backgroundTintedImage(color: UIColor(hexString: "CCCCCC"))

        button.setBackgroundImage(image, for: .normal)
        button.setBackgroundImage(disabledImage, for: .disabled)
        button.setBackgroundImage(highlightedImage, for: .highlighted)

        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white, for: .highlighted)
        button.setTitleColor(UIColor(white: 0.5, alpha: 0.7), for: .disabled)

        return button
    }

    class var roundedButton: UIButton {
        let disabledImage = UIImage.backgroundTintedImage(color: UIColor(hexString: "EEEEEE"))
        let highlightedImage = UIImage.backgroundTintedImage(color: UIColor(hexString: "DDDDDD"))

        let button = UIButton.roundedButton(backgroundColor: UIColor(hexString: "BBBBBB"))
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setBackgroundImage(disabledImage, for: .disabled)
        button.setBackgroundImage(highlightedImage, for: .highlighted)

        button.setTitleColor(Color.text, for: .normal)
        button.setTitleColor(UIColor(hexString: "BBBBBB"), for: .highlighted)
        button.setTitleColor(UIColor(hexString: "CCCCCC"), for: .disabled)

        return button
    }

    class var highlightButton: UIButton {
        return UIButton.roundedButton(backgroundColor: Color.highlight)
    }

}
