//
//  ArtInstallation.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/5/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import Foundation
import UIKit
//import CoreLocation

struct SAOTag {
    var tagName: String
}

struct SAOLocation {
    var locationName: String
//    var coordinates: CLLocation
}

struct ArtInstallation {
    var imageNames : [String]
    var location: SAOLocation
    var tags: [SAOTag]
    var likes: Int
    var nearbyArt: [String]
    
    var primaryImage: UIImage? {
        return UIImage(named: imageNames.first ?? "ImageNotFound")
    }
}

struct SampleData {
    static let dataSource = [
        ArtInstallation(
            imageNames: ["1"],
            location: SAOLocation(locationName: "201 S Rosalind Ave"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["2"],
            location: SAOLocation(locationName: "106 E Church St"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["3"],
            location: SAOLocation(locationName: "408 N Summerlin Ave"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["4"],
            location: SAOLocation(locationName: "698 North Mills Ave"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["5"],
            location: SAOLocation(locationName: "1198 East Marks St"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["6"],
            location: SAOLocation(locationName: "623 N Summerlin Ave"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["7"],
            location: SAOLocation(locationName: "29 W Church St"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["8"],
            location: SAOLocation(locationName: "217 E Central Blvd"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["9"],
            location: SAOLocation(locationName: "289 E Robinson St"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["10"],
            location: SAOLocation(locationName: "51 E Jefferson St"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["11"],
            location: SAOLocation(locationName: "145 E Pine St"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["12"],
            location: SAOLocation(locationName: "209 Liberty Ave"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["13"],
            location: SAOLocation(locationName: "68 N Rosalind Ave"),
            tags: [],
            likes: 0,
            nearbyArt: []
        ),
        ArtInstallation(
            imageNames: ["14"],
            location: SAOLocation(locationName: "203 E Central Blvd"),
            tags: [],
            likes: 0,
            nearbyArt: []
        )
    ]
}
