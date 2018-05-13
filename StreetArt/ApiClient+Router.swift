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
        case authenticate
        case register
        case passwordForgot
        case passwordValidateToken
        case passwordReset
        case passwordUpdate
        case submissions
        case mySubmissions
        case favorites
        case favorite(submissionId: Int)
        case unfavorite(submissionId: Int)

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
            case .authenticate:
                return "authenticate"
            case .register:
                return "users/register"
            case .passwordForgot:
                return "password/forgot"
            case .passwordValidateToken:
                return "password/validate_token"
            case .passwordReset:
                return "password/reset"
            case .passwordUpdate:
                return "password/update"
            case .submissions:
                return "submissions"
            case .mySubmissions:
                return "submissions/mine"
            case .favorites:
                return "submissions/favorites"
            case .favorite(let submissionId):
                return "submissions/\(submissionId)/favorite"
            case .unfavorite(let submissionId):
                return "submissions/\(submissionId)/unfavorite"
            }
        }

        func asURL() throws -> URL {
            let urlString = Router.URLString + path
            return try urlString.asURL()
        }
    }

}
