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
