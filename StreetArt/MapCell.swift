//
//  MapCell.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/3/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import MapKit
import SnapKit

class MapCell: UITableViewCell {

    struct Constants {
        static let height: CGFloat = 200.0
    }

    var mapView: MKMapView!

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.accessoryType = .none

        mapView = MKMapView()
        mapView.isUserInteractionEnabled = false

        self.contentView.addSubview(mapView)

        // Auto Layout

        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            mapView.alpha = 0.75
        } else {
            mapView.alpha = 1.0
        }
    }

}
