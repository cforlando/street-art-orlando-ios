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
        completionHandler( Result.Success(SampleData.dataSource) )
      }
    }
  }

  private static func debugLog( _ msg: String) {
    if DEBUG_LOGGING_ENABLED {
      print( msg )
    }
  }
}
