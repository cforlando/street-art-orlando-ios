//
//  DataManager.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/11/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import Alamofire

class DataManager {
    static let shared = DataManager()
}

extension DataManager {

    func authenticateAnonymousUser(completionHandler: @escaping ((Result<Bool>) -> Void)) {
        if ApiClient.shared.isAuthenticated {
            completionHandler(.success(true))
        } else {
            ApiClient.shared.registerAnonymousUser { [weak self] (result) in
                guard let _ = self else {
                    return
                }

                completionHandler(result)
            }
        }
    }

}
