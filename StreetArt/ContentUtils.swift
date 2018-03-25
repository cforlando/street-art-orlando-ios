//
//  ContentUtils.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

typealias ContentSectionArray = [ContentSection]

struct ContentSection {

    var groupIdentifier: String?
    var identifier: String?
    var title: String?
    var footer: String?
    var rows = ContentRowArray()
    var userInfo = [String: Any]()

    init(title: String?, rows: ContentRowArray) {
        self.title = title
        self.rows = rows
    }
}

typealias ContentRowArray = [ContentRow]

struct ContentRow {

    var identifier: String?
    var groupIdentifier: String?
    var text: String?
    var detail: String?
    var userInfo = [String: Any]()
    var object: Any?
    var height: CGFloat?

    init() {
        // empty row
    }

    init(text: String?, detail: String? = nil) {
        self.text = text
        self.detail = detail
    }

    init(object: Any?) {
        self.object = object
    }

}

