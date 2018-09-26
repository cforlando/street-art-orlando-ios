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

    var locationManager: CLLocationManager!
    var currentLocation: MKUserLocation?

    var submission: Submission!

    init(submission: Submission) {
        super.init(nibName: nil, bundle: nil)
        self.title = MAP_TEXT
        self.submission = submission
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
        mapView.delegate = self
        self.view.addSubview(mapView)

        // Auto Layout

        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        locationManager = CLLocationManager()
        locationManager.delegate = self

        if let annotation = submission.annotation {
            let region = MKCoordinateRegion(center: annotation.coordinate, span: Defaults.mapSpan)
            mapView.setRegion(region, animated: false)
            mapView.addAnnotation(annotation)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        mapView.showsUserLocation = false
        currentLocation = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: Methods

extension MapViewController {

    func updateAnnotations(animated: Bool = false) {
        var zoomRect = MKMapRect.null

        for annotation in mapView.annotations {
            if annotation is SubmissionAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }

        if let annotation = submission.annotation {
            mapView.addAnnotation(annotation)
        }

        for annotation in mapView.annotations {
            dLog("processing annotation: \(annotation)")

            let point = MKMapPoint.init(annotation.coordinate)
            let rect = MKMapRect.init(x: point.x, y: point.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.union(rect)
        }

        let inset = -zoomRect.size.width * 0.1
        mapView.setVisibleMapRect(zoomRect.insetBy(dx: inset, dy: inset), animated: animated)
    }

    func openMaps() {
        guard let from = currentLocation?.coordinate, let to = submission.coordinate else {
            return
        }

        var launchOptions = [String: Any]()
        launchOptions[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving

        let fromPlacemark = MKPlacemark(coordinate: from, addressDictionary: nil)
        let fromLocation = MKMapItem(placemark: fromPlacemark)
        fromLocation.name = CURRENT_LOCATION_TEXT

        let toPlacemark = MKPlacemark(coordinate: to, addressDictionary: nil)
        let toLocation = MKMapItem(placemark: toPlacemark)
        toLocation.name = submission.title ?? STREET_ART_LOCATION_TEXT

        LocalAnalytics.shared.customEvent(.getDirections, submission: submission)
        MKMapItem.openMaps(with: [fromLocation, toLocation], launchOptions: launchOptions)
    }

}

// MARK: Selector Methods

extension MapViewController {

    @objc func dismissAction(_ sender: AnyObject?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func actionsAction(_ sender: AnyObject?) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let directionsAction = UIAlertAction(title: DIRECTIONS_TEXT, style: .default) { [unowned self] (action) in
            self.openMaps()
        }

        actionSheet.addAction(directionsAction)

        let cancelAction = UIAlertAction(title: CANCEL_TEXT, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        self.navigationController?.present(actionSheet, animated: true, completion: nil)
    }

}

// MARK: - LocationManagerDelegate Methods

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        dLog("\(String(status.rawValue))")
    }

}

// MARK: - MKMapViewDelegate Methods

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        dLog("user location: \(userLocation)")

        if currentLocation == nil {
            currentLocation = userLocation
            updateAnnotations(animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        updateAnnotations(animated: true)
    }

}
