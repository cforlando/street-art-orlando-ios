//
//  ArtInstallation.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/5/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import Foundation
import UIKit
//import CoreLocation

struct SAOTag {
    var tagName: String
}

struct SAOLocation {
    var locationName: String
//    var coordinates: CLLocation
}

struct ArtInstallation {
    var imageNames : [String]
    var location: SAOLocation
    var tags: [SAOTag]
    var likes: Int
    var nearbyArt: [String]
    
    var primaryImage: UIImage? {
        return UIImage(named: imageNames.first ?? "ImageNotFound")
    }
    
    func separatedTagsString() -> String {
        var tagsString: String = ""
        
        for tag in tags {
            if !tag.tagName.isEmpty {
                if !tagsString.isEmpty {
                    tagsString += ";"
                }
                
                tagsString += tag.tagName
            }
        }
        
        return tagsString
    }
}
