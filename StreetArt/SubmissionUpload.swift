//
//  SubmissionUpload.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/18/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import CoreLocation

class SubmissionUpload {

    var name = String()
    var image = UIImage()
    var coordinate: CLLocationCoordinate2D?

    init(name: String, image: UIImage, coordinate: CLLocationCoordinate2D? = nil) {
        self.name = name
        self.image = image
        self.coordinate = coordinate
    }

}

// MARK: - Methods

extension SubmissionUpload {

    var base64ImageString: String? {
        guard let string = self.image.toBase64String() else {
            return nil
        }

        return "data:image/jpeg;base64," + string
    }

}
