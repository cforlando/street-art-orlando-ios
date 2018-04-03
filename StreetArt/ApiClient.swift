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
        static let production = "https://example.com/"
    }

    struct Config {
        #if OSA_PRODUCTION
        // Used for App Store Builds. DO NOT CHANGE!!
        static let URLString = URLHosts.forward  // DO NOT CHANGE EVER!!!
        #else
        // Used for DEBUG BUILDS ONLY
        static let URLString = URLHosts.forward
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

    var anonymousEmail: String {
        let identifier = Settings.shared.deviceIdentifier
        return identifier + "@riveradev.com"
    }

    var anonymousPassword: String {
        return Settings.shared.deviceIdentifier
    }

    func registerAnonymousUser(completionHandler: @escaping ((Result<Bool>) -> Void)) {
        let route = Router.register

        let parameters: Parameters = [
            "email": anonymousEmail,
            "password": anonymousPassword,
            "anonymous": true
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
                        completionHandler(.success(true))
                    } else {
                        let error = NSError.customError(message: "unknown error")
                        completionHandler(.failure(error))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func authenticateAnonymousUser(completionHandler: @escaping ((Result<Bool>) -> Void)) {
        let route = Router.authenticate

        let parameters: Parameters = [
            "email": anonymousEmail,
            "password": anonymousPassword
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
                        completionHandler(.success(true))
                    } else {
                        let error = NSError.customError(message: "unknown error")
                        completionHandler(.failure(error))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

}

// MARK: Submissions

extension ApiClient {

    func uploadSubmission(upload: SubmissionUpload, completionHandler: @escaping ((Result<Bool>) -> Void)) {
        let route = Router.submissions

        var parameters: Parameters = [
            "title": upload.name
        ]

        if let imageString = upload.base64ImageString {
            parameters["photo"] = imageString
        }

        if let coordinate = upload.coordinate {
            parameters["latitude"] = coordinate.latitude
            parameters["longitude"] = coordinate.longitude
        }

        sessionManager.request(route, method: .post, parameters: parameters, headers: additionalHeaders)
            .validate()
            .responseSwiftyJSON { [weak self] (response) in
                guard let _ = self else {
                    return
                }

                switch response.result {
                case .success:
                    completionHandler(.success(true))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        }
    }

    func fetchSubmissions(page: Int, completionHandler: @escaping ((Result<SubmissionContainer>) -> Void)) {
        let route = Router.submissions

        let parameters = [ "page": page ]

        sessionManager.request(route, parameters: parameters, headers: additionalHeaders).validate().responseSwiftyJSON { [weak self] (response) in
            guard let _ = self else {
                return
            }

            switch response.result {
            case .success(let json):
                dLog("submissions: \(json["meta"])")

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

}
