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

    var name = String()
    var thumbURLString = String()
    var imageURLString = String()

    init?(json: JSON) {
        guard let name = json["name"].string else {
            return nil
        }

        guard let thumbURLString = json["thumb_url"].string else {
            return nil
        }

        guard let imageURLString = json["image_url"].string else {
            return nil
        }

        self.name = name
        self.thumbURLString = thumbURLString
        self.imageURLString = imageURLString
    }

}

// MARK: Methods

extension Submission {

    var thumbURL: URL? {
        return URL(string: thumbURLString)
    }

    var imageURL: URL? {
        return URL(string: imageURLString)
    }

}

// MARK: - Container

class SubmissionContainer {
    var total: Int = 0
    var currentPage: Int = 0
    var perPage: Int = 0
    var submissions = SubmissionArray()

    init?(json: JSON) {
        guard let total = json["total"].int else {
            return nil
        }

        guard let currentPage = json["current"].int else {
            return nil
        }

        guard let perPage = json["per_page"].int else {
            return nil
        }

        self.total = total
        self.currentPage = currentPage
        self.perPage = perPage

        let submissionsRaw = json["submissions"].arrayValue
        for raw in submissionsRaw {
            if let submission = Submission(json: raw) {
                submissions.append(submission)
            }
        }
    }

}
