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

    var image = UIImage()
    var title: String?
    var artist: String?
    var coordinate: CLLocationCoordinate2D?

    init(image: UIImage, title: String?, artist: String? = nil, coordinate: CLLocationCoordinate2D? = nil) {
        self.image = image
        self.title = title
        self.artist = artist
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
