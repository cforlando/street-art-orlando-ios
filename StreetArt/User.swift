//
//  User.swift
//  StreetArt
//
//  Created by Axel Rivera on 1/6/19.
//  Copyright © 2019 Axel Rivera. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {

    var id = 0
    var name: String?
    var nickname = String()
    var vip = false

    init?(json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }

        self.id = id
        self.name = json["name"].string
        self.nickname = json["nickname"].stringValue
        self.vip = json["vip"].boolValue
    }

}
