//
//  ApiClient.swift
//  Street Art Orlando
//
//  Created by James Reichley on 3/8/17.
//  Copyright © 2017 Code For Orlando. All rights reserved.
//

import Foundation

private let DEBUG_LOGGING_ENABLED = false

enum ApiError: Error {
  // TODO(jpr): error types
}

enum Result<T> {
  case Success(T)
  case Failure(ApiError)
}


class ApiClient {
  // TODO(jpr): make this registerable?
  private static let _sharedClient = ApiClient()
  
  public static func shared() -> ApiClient {
    return _sharedClient
  }
  
  // JPR: make private to ensure access is gated through the `shared` method
  private init() {}
  
  public func fetchInstallations( _ completionHandler: @escaping (Result<[ArtInstallation]>) -> Void ) {
    let startTime = Date.timeIntervalSinceReferenceDate
    DispatchQueue.global(qos: .userInitiated).async {
      // TODO(jpr): hit backend
      Thread.sleep(forTimeInterval: 0.5)
      
      let endTime = Date.timeIntervalSinceReferenceDate
      ApiClient.debugLog( "Installations fetched in \(endTime - startTime) seconds" )
      DispatchQueue.main.async {
        completionHandler( Result.Success(SampleInstallations) )
      }
    }
  }
  
  private static func debugLog( _ msg: String) {
    if DEBUG_LOGGING_ENABLED {
      print( msg )
    }
  }
}


// MARK: Dummy data

private let SampleInstallations = [
  ArtInstallation(
    imageNames: ["1"],
    location: SAOLocation(locationName: "201 S Rosalind Ave"),
    tags: [
      SAOTag(tagName: "Scupture"),
      SAOTag(tagName: "Graffiti"),
      SAOTag(tagName: "Modern"),
      SAOTag(tagName: "Limited Time")
    ],
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
