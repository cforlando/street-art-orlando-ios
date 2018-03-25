//
//  UIImage+Additions.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/11/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation

extension UIImage {

    func toBase64String() -> String? {
        var string: String?
        if let data = UIImageJPEGRepresentation(self, 1.0) {
            string = data.base64EncodedString(options: [])
        }

        return string
    }

}

extension String {

    func base64StringToImage() -> UIImage? {
        var image: UIImage?
        if let data = Data(base64Encoded: self, options: []) {
            image = UIImage(data: data)
        }

        return image
    }

}
