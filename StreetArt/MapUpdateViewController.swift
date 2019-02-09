//
//  MapUpdateViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 5/31/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

import UIKit
import MapKit

class MapUpdateViewController: UIViewController {

    var mapView: MKMapView!
    var mapDot = MapDot()

    var cancelBlock: (() -> Void)?
    var saveBlock: ((CLLocationCoordinate2D) -> Void)?

    var currentLocation: CLLocation?

    var isDotVisible = false

    init(coordinate: CLLocationCoordinate2D? = nil) {
        super.init(nibName: nil, bundle: nil)

        if let coordinate = coordinate {
            self.currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
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

        if let _ = cancelBlock {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: CANCEL_TEXT,
                style: .plain,
                target: self,
                action: #selector(dismissAction(_:))
            )
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: UPDATE_TEXT,
            style: .done,
            target: self,
            action: #selector(saveAction(_:))
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let currentLocation = self.currentLocation, !isDotVisible{
            let origin = mapView.convert(currentLocation.coordinate, toPointTo: self.view)
            mapDot.center = origin
            mapView.addSubview(mapDot)

            isDotVisible = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: Selector Methods

extension MapUpdateViewController {

    @objc func saveAction(_ sender: AnyObject?) {
        let coordinate = mapView.convert(mapDot.center, toCoordinateFrom: mapView)
        saveBlock?(coordinate)
    }

    @objc func dismissAction(_ sender: AnyObject?) {
        cancelBlock?()
    }

}
