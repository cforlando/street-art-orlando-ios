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

    var overlayView: UIView!
    var mapView: MKMapView!

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.accessoryType = .none

        overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.alpha = 0

        self.contentView.addSubview(overlayView)

        mapView = MKMapView()
        mapView.isUserInteractionEnabled = false

        self.contentView.addSubview(mapView)

        setupConstraints()
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
            self.contentView.bringSubviewToFront(overlayView)
            overlayView.alpha = 1.0
        } else {
            self.contentView.sendSubviewToBack(overlayView)
            overlayView.alpha = 0.0
        }
    }

}

// MARK: - Methods

extension MapCell {

    func setupConstraints() {
        overlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

}
