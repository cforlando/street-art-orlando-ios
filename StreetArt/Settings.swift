//
//  Settings.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/11/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation

class Settings {
    struct Constants {
        static let deviceIdentifier = "cfo_device_identifier"
        static let authToken = "cfo_auth_token"
    }

    static let shared = Settings()

    var deviceIdentifier: String {
        var identifier = UserDefaults.standard.object(forKey: Constants.deviceIdentifier) as? String
        if identifier == nil {
            identifier = uniqueIdentifier()
            UserDefaults.standard.set(identifier, forKey: Constants.deviceIdentifier)
            UserDefaults.standard.synchronize()
        }

        return identifier!
    }

    var authToken: String? {
        return UserDefaults.standard.object(forKey: Constants.authToken) as? String
    }

    func set(authToken value: String?) {
        UserDefaults.standard.set(value, forKey: Constants.authToken)
        UserDefaults.standard.synchronize()
    }
    
}
