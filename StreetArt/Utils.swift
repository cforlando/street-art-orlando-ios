//
//  Utils.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/8/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

func singlePixelLineMetric() -> CGFloat {
    return 1.0 / UIScreen.main.scale
}

func uniqueIdentifier() -> String {
    return UUID().uuidString
}

func isCameraAvailable() -> Bool {
    return UIImagePickerController.isSourceTypeAvailable(.camera)
}

func isPhotoLibraryAvailable() -> Bool {
    return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
}

func systemVersionAndBuild() -> (String, String) {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return (version, build)
}

