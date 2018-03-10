//
//  StreetArt.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation

class StreetArt {

    var name = String()
    var image = UIImage()

    init() {
        // Empty Object
    }

    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }

}

extension StreetArt {

    class var sample: StreetArt {
        return StreetArt(name: "Fight Club by Danny Rock", image: #imageLiteral(resourceName: "mills50-art"))
    }

}
