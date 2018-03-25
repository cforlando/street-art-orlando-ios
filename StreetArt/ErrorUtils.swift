//
//  ErrorUtils.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/11/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation

private let SERVER_DOMAIN = "com.codefororlando.error"

extension NSError {

    class func customError(message: String) -> NSError {
        let userInfo = [ NSLocalizedDescriptionKey: message]
        let error = NSError(domain: SERVER_DOMAIN, code: 0, userInfo: userInfo)
        return error
    }

}
