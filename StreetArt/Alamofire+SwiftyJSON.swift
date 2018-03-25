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
                return .failure(error)
            }

            do {
                let object: Any = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
                let json = JSON(object)

                if let error = error {
                    return .failure(error)
                }

                return .success(json)
            } catch {
                return .failure(NSError.customError(message: "server error"))
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
