//
//  UIImage+Additions.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/7/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

extension UIImage {

    class var templateImage: UIImage {
        let size = CGSize(width: 1.0, height: 1.0)

        UIGraphicsBeginImageContextWithOptions(size, true, 0)

        UIColor.black.setFill()
        UIRectFill(CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image!.withRenderingMode(.alwaysTemplate)
    }

    class var backgroundTemplateImage: UIImage {
        let image = UIImage.templateImage
        let resizableImage = image.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile)
        return resizableImage.withRenderingMode(.alwaysTemplate)
    }

    func tintedImage(color: UIColor, blendingMode: CGBlendMode = CGBlendMode.destinationIn) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)

        color.setFill()
        let bounds = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: blendingMode, alpha: 1.0)

        if blendingMode.rawValue != CGBlendMode.destinationIn.rawValue {
            self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }

    class func tintedImage(name: String, color: UIColor) -> UIImage? {
        let image = UIImage(named: name)
        return image?.tintedImage(color: color)
    }

    func tintedImage(color: UIColor) -> UIImage? {
        return self.tintedImage(color: color, blendingMode: CGBlendMode.destinationIn)
    }

    class func backgroundTintedImage(color: UIColor) -> UIImage? {
        return UIImage.backgroundTemplateImage.tintedImage(color:color)
    }

}
