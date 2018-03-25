//
//  SubmissionUpload.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/18/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation

class SubmissionUpload {

    var name = String()
    var image: UIImage?

    init() {
        // Initialization Code
    }

}

// MARK: - Methods

extension SubmissionUpload {

    var base64ImageString: String? {
        guard let image = self.image else {
            return nil
        }

        return image.toBase64String()
    }

}
