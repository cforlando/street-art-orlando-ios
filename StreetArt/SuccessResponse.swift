//
//  SuccessResponse.swift
//  StreetArt
//
//  Created by Axel Rivera on 5/13/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SuccessResponse {
    var success = false
    var message: String?

    init(json: JSON) {
        success = json["success"].boolValue
        message = json["message"].string
    }

}
