//
//  Alamofire+SwiftyJSON.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/18/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

fileprivate let emptyDataStatusCodes: Set<Int> = [204, 205]

enum ServerError: Error, CustomStringConvertible {
    case message(String)
    case system(Error)
    case generic
    case unknown

    var description: String {
        switch self {
        case .message(let message):
            return message
        case .system(let error):
            return error.localizedDescription
        case .generic:
            return "Network Error"
        case .unknown:
            return "Unknown Error"
        }
    }
}

extension DataRequest {

    static func swiftyJSONResponseSerializer() -> DataResponseSerializer<JSON> {
        return DataResponseSerializer { request, response, data, error in
            if let response = response, emptyDataStatusCodes.contains(response.statusCode) {
                return .success(JSON.null)
            }

            // Use Alamofire's existing data serializer to extract the data, passing the error as nil, as it has
            // already been handled.
            let result = Request.serializeResponseData(response: response, data: data, error: nil)
            let responseData = result.value ?? Data()

            if let error = error, responseData.isEmpty {
                return .failure(ServerError.system(error))
            }

            do {
                let object: Any = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
                let json = JSON(object)

                if let _ = error {
                    var errorMessage: String?
                    if let string = json["error"].string {
                        errorMessage = string
                    } else if let array = json["errors"].array {
                        errorMessage = array.map { $0.stringValue }.joined(separator: "\n")
                    }

                    if let message = errorMessage {
                        return .failure(ServerError.message(message))
                    }

                    return .failure(ServerError.unknown)
                }

                return .success(json)
            } catch {
                return .failure(ServerError.generic)
            }
        }
    }

    @discardableResult
    func responseSwiftyJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<JSON>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.swiftyJSONResponseSerializer(),
            completionHandler: completionHandler
        )
    }

}
