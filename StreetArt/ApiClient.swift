//
//  ApiClient.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/10/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import Alamofire

class ApiClient {
    struct URLHosts {
        static let forward = "https://sao-sharingan.fwd.wf/api/"
        static let localhost = "http://localhost:3000/"

        // Production constants should never be changed
        static let production = "https://cfo-street-art.herokuapp.com/api/"
    }

    struct Config {
        #if OSA_PRODUCTION
        // Used for App Store Builds. DO NOT CHANGE!!
        static let URLString = URLHosts.production  // DO NOT CHANGE EVER!!!
        #else
        // Used for DEBUG BUILDS ONLY
        static let URLString = URLHosts.production
        #endif
    }

    static let shared = ApiClient()

    private var authTokenString: String? {
        willSet(newValue) {
            Settings.shared.set(authToken: newValue)
        }
    }

    private var authToken: String? {
        var token = authTokenString
        if token == nil {
            token = Settings.shared.authToken
            authTokenString = token
        }

        return token
    }

    var isAuthenticated: Bool {
        return authToken != nil
    }

    lazy var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default

        var headers = SessionManager.defaultHTTPHeaders
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
        configuration.httpAdditionalHeaders = headers

        return Alamofire.SessionManager(configuration: configuration)
    }()

    var additionalHeaders: HTTPHeaders {
        let headers = [
            "Authorization": authToken ?? String()
        ]

        return headers
    }

}

// MARK: - Registration and Authentication

extension ApiClient {

    func register(email: String, password: String, name: String?, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.register

        var parameters = [
            "email": email,
            "password": password
        ]

        if let name = name {
            parameters["name"] = name
        }

        sessionManager.request(route, method: .post, parameters: parameters)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    completionHandler(.success(SuccessResponse(json: json)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func authenticate(username: String, password: String, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.authenticate

        let parameters = [
            "email": username,
            "password": password
        ]

        sessionManager.request(route, method: .post, parameters: parameters)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    if let authToken = json["auth_token"].string {
                        self?.authTokenString = authToken
                        completionHandler(.success(SuccessResponse(json: json)))
                    } else {
                        completionHandler(.failure(ServerError.unknown))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func logout() {
        authTokenString = nil
    }

}

// MARK: Password

extension ApiClient {

    func passwordForgot(email: String, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.passwordForgot

        let parameters = [ "email": email ]

        sessionManager.request(route, method: .post, parameters: parameters)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    completionHandler(.success(SuccessResponse(json: json)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func passwordValidateToken(email: String, token: String, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.passwordValidateToken

        let parameters = [ "email": email, "token": token ]

        sessionManager.request(route, method: .post, parameters: parameters)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    completionHandler(.success(SuccessResponse(json: json)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func passwordReset(email: String, token: String, password: String, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.passwordReset

        let parameters = [ "email": email, "token": token, "password": password ]

        sessionManager.request(route, method: .post, parameters: parameters)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    completionHandler(.success(SuccessResponse(json: json)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func passwordUpdate(password: String, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.passwordUpdate

        let parameters = [ "password": password ]

        sessionManager.request(route, method: .put, parameters: parameters, headers: additionalHeaders)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    completionHandler(.success(SuccessResponse(json: json)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

}

// MARK: Submissions

extension ApiClient {

    func upload(submission upload: SubmissionUpload, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.submissions
        var parameters = Parameters()

        if let imageString = upload.base64ImageString {
            parameters["photo"] = imageString
        }

        if let title = upload.title {
            parameters["title"] = title
        }

        if let artist = upload.artist {
            parameters["artist"] = artist
        }

        if let locationNote = upload.locationNote {
            parameters["location_note"] = locationNote
        }

        parameters["latitude"] = upload.coordinate.latitude
        parameters["longitude"] = upload.coordinate.longitude

        sessionManager.request(route, method: .post, parameters: parameters, headers: additionalHeaders)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    completionHandler(.success(SuccessResponse(json: json)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func submissions(page: Int, completionHandler: @escaping ((Result<SubmissionContainer>) -> Void)) {
        let route = Router.submissions
        let parameters = [ "page": page ]

        sessionManager.request(route, parameters: parameters, headers: additionalHeaders)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    if let container = SubmissionContainer(json: json) {
                        completionHandler(.success(container))
                    } else {
                        let error = NSError.customError(message: "unknown error")
                        completionHandler(.failure(error))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func mySubmissions(completionHandler: @escaping ((Result<SubmissionArray>) -> Void)) {
        let route = Router.mySubmissions

        sessionManager.request(route, method: .get, headers: additionalHeaders).validate().responseSwiftyJSON { [weak self] (response) in
            guard let _ = self else {
                return
            }

            switch response.result {
            case .success(let json):
                var submissions = SubmissionArray()

                for raw in json["submissions"].arrayValue {
                    if let submission = Submission(json: raw) {
                        submissions.append(submission)
                    }
                }

                completionHandler(.success(submissions))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func favorites(completionHandler: @escaping ((Result<SubmissionArray>) -> Void)) {
        let route = Router.favorites

        sessionManager.request(route, method: .get, headers: additionalHeaders)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    var submissions = SubmissionArray()

                    for raw in json["submissions"].arrayValue {
                        if let submission = Submission(json: raw) {
                            submissions.append(submission)
                        }
                    }

                    completionHandler(.success(submissions))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func favorite(submission: Submission, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.favorite(submissionId: submission.id)

        sessionManager.request(route, method: .post, headers: additionalHeaders)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    completionHandler(.success(SuccessResponse(json: json)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func unfavorite(submission: Submission, completionHandler: @escaping ((Result<SuccessResponse>) -> Void)) {
        let route = Router.unfavorite(submissionId: submission.id)

        sessionManager.request(route, method: .delete, headers: additionalHeaders)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success(let json):
                    completionHandler(.success(SuccessResponse(json: json)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

}
