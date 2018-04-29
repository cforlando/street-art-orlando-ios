//
//  AppConfig.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/10/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import MapKit

struct Defaults {
    static let maxImageResizeInPixels: CGFloat = 2048.0
    static let defaultImageHeight: CGFloat = 250.0

    static let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    // Orlando, FL
    static let mapCoordinate = CLLocationCoordinate2D(latitude: 28.538336, longitude: -81.379234)

    static let maxCharactersInTextView: Int = 200
}

extension Notification.Name {
    static let userDidLogin = Notification.Name("cfo_user_did_login")
    static let userDidLogout = Notification.Name("cfo_user_did_logout")
}
