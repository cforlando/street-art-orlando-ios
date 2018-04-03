//
//  Submission.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

typealias SubmissionArray = [Submission]

struct Submission {

    var id = 0
    var title = String()
    var description: String?

    var latitude: Double?
    var longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = self.latitude, let longitude = self.longitude else {
            return nil
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return CLLocationCoordinate2DIsValid(coordinate) ? coordinate : nil
    }

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

        self.latitude = json["latitude"].double
        self.longitude = json["longitude"].double

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

extension Submission: Equatable {

    static func == (lhs: Submission, rhs: Submission) -> Bool {
        return lhs.id == rhs.id
    }

}

// MARK: - Container

struct SubmissionContainer {

    var currentPage: Int = 0
    var nextPage: Int?
    var total: Int = 0
    var totalPages: Int = 0

    var submissions = SubmissionArray()

    init?(json: JSON) {
        guard let currentPage = json["meta"]["current_page"].int else {
            return nil
        }

        guard let total = json["meta"]["total"].int else {
            return nil
        }

        guard let totalPages = json["meta"]["total_pages"].int else {
            return nil
        }

        self.currentPage = currentPage
        self.nextPage = json["meta"]["next_page"].int
        self.total = total
        self.totalPages = totalPages

        let rawSubmissions = json["submissions"].arrayValue

        for raw in rawSubmissions {
            if let submission = Submission(json: raw) {
                submissions.append(submission)
            }
        }
    }

}

