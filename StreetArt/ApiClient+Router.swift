//
//  ApiClient+Router.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/10/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import Alamofire

extension ApiClient {

    enum Router: URLConvertible {
        case register
        case authenticate
        case submissions

        static var URLString: String {
            let string = Config.URLString
            if let char = string.last, char == "/" {
                return string
            } else {
                return string + "/"
            }
        }

        var path: String {
            switch self {
            case .register:
                return "register"
            case .authenticate:
                return "authenticate"
            case .submissions:
                return "submissions"
            }
        }

        func asURL() throws -> URL {
            let urlString = Router.URLString + path
            return try urlString.asURL()
        }
    }

}
