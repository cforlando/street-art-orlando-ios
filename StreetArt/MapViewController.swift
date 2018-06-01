//
//  MapViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/8/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var mapView: MKMapView!

    var currentLocation: CLLocation?

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = MAP_TEXT
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: DONE_TEXT,
            style: .done,
            target: self,
            action: #selector(dismissAction(_:))
        )

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(actionsAction(_:))
        )

        mapView = MKMapView()
        self.view.addSubview(mapView)

        // Auto Layout

        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        if let currentLocation = self.currentLocation {
            let region = MKCoordinateRegion(center: currentLocation.coordinate, span: Defaults.mapSpan)
            mapView.setRegion(region, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: Selector Methods

extension MapViewController {

    @objc func dismissAction(_ sender: AnyObject?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func actionsAction(_ sender: AnyObject?) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let directionsAction = UIAlertAction(title: DIRECTIONS_TEXT, style: .default) { (action) in

        }

        actionSheet.addAction(directionsAction)

        let cancelAction = UIAlertAction(title: CANCEL_TEXT, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        self.navigationController?.present(actionSheet, animated: true, completion: nil)
    }

}
