//
//  Submission.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias SubmissionArray = [Submission]

class Submission {

    var id = 0
    var title = String()
    var description: String?

    var photoURLString = String()
    var thumbURLString = String()
    var tinyURLString = String()

    init?(json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }

        guard let title = json["title"].string else {
            return nil
        }

        guard let photoURLString = json["photo_url"].string else {
            return nil
        }

        guard let thumbURLString = json["thumb_url"].string else {
            return nil
        }

        guard let tinyURLString = json["tiny_url"].string else {
            return nil
        }

        self.id = id
        self.title = title
        self.description = json["description"].string

        self.photoURLString = photoURLString
        self.thumbURLString = thumbURLString
        self.tinyURLString = tinyURLString
    }

}

// MARK: Methods

extension Submission {

    var photoURL: URL? {
        return URL(string: photoURLString)
    }

    var thumbURL: URL? {
        return URL(string: thumbURLString)
    }

    var tinyURL: URL? {
        return URL(string: tinyURLString)
    }

}
