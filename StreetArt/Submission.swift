//
//  Submission.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import SwiftyJSON
import MapKit

typealias SubmissionArray = [Submission]

struct Submission {

    enum Status: String {
        case processing = "processing"
        case pending = "pending"
        case approved = "approved"
        case rejected = "rejected"

        init(string: String) {
            self = Status(rawValue: string) ?? .processing
        }

        var color: UIColor {
            switch self {
            case .processing:
                return UIColor(hexString: "E6C229")
            case .pending:
                return UIColor(hexString: "E6C229")
            case .approved:
                return UIColor(hexString: "4FC78F")
            case .rejected:
                return UIColor(hexString: "D11149")
            }
        }

        var labelString: String {
            switch self {
            case .processing:
                return PROCESSING_TEXT
            case .pending:
                return PENDING_TEXT
            case .approved:
                return APPROVED_TEXT
            case .rejected:
                return REJECTED_TEXT
            }
        }
    }

    var id = 0
    var status = Status.processing
    var title: String?
    var description: String?
    var artist: String?

    var latitude: Double?
    var longitude: Double?

    var locationNote: String?

    var favorite = false
    var nickname: String?

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
        self.status = Status(string: json["status"].stringValue)

        if let title = json["title"].string, !title.isEmpty {
            self.title = title
        }

        if let description = json["description"].string, !description.isEmpty {
            self.description = description
        }

        if let artist = json["artist"].string, !artist.isEmpty {
            self.artist = artist
        }

        self.latitude = json["latitude"].double
        self.longitude = json["longitude"].double

        if let locationNote = json["location_note"].string, !locationNote.isEmpty {
            self.locationNote = locationNote
        }

        self.favorite = json["favorite"].boolValue
        self.nickname = json["nickname"].string

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

// MARK: Equal

extension Submission: Equatable {

    static func == (lhs: Submission, rhs: Submission) -> Bool {
        return lhs.id == rhs.id
    }

}

// MARK: Annotation

extension Submission {

    var annotation: SubmissionAnnotation? {
        guard let coordinate = self.coordinate else {
            return nil
        }

        return SubmissionAnnotation(title: title, coordinate: coordinate)
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

// MARK: - Annotation

class SubmissionAnnotation: NSObject, MKAnnotation {

    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }

    var title: String?
    var coordinate: CLLocationCoordinate2D

    var isValidCoordinate: Bool {
        return CLLocationCoordinate2DIsValid(coordinate)
    }

}

