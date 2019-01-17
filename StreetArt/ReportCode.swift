//
//  ReportCode.swift
//  StreetArt
//
//  Created by Axel Rivera on 1/16/19.
//  Copyright © 2019 Axel Rivera. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ReportCodeArray = [ReportCode]

struct ReportCode {

    var code: Int
    var text: String

    init?(json: JSON) {
        guard let code = json["code"].int else {
            return nil
        }

        guard let text = json["text"].string else {
            return nil
        }

        self.code = code
        self.text = text
    }

}

// MARK: Equal

extension ReportCode: Equatable {

    static func == (lhs: ReportCode, rhs: ReportCode) -> Bool {
        return lhs.code == rhs.code
    }

}
