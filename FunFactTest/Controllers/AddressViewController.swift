//
//  AddressViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 7/26/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class AddressViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: CustomButton!
    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController?
    var selectedPin: MKPlacemark?
    var callback: ((AddressData) -> Void)?
    
    struct AddressData {
        var address: String?
        var landmarkName: String?
        var coordinate: CLLocationCoordinate2D?
        var city: String?
        var state: String?
        var country: String?
        var zipcode: String?
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.backgroundColor = Colors.seagreenColor
        mapView.bringSubviewToFront(submitButton)
        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .darkGray
        navigationController?.navigationBar.prefersLargeTitles = false
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable")
            as! LocationSearchTableViewController // swiftlint:disable:this force_cast
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont(name: "Avenir Next", size: 14.0)
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func submitAction(_ sender: Any) {
        let add = AddressData(address: (selectedPin?.subThoroughfare ?? "") + " " + (selectedPin?.thoroughfare ?? ""),
                              landmarkName: selectedPin!.name ?? "",
                              coordinate: selectedPin!.coordinate,
                              city: selectedPin!.locality ?? "",
                              state: selectedPin!.administrativeArea ?? "",
                              country: selectedPin!.isoCountryCode ?? "",
                              zipcode: selectedPin!.postalCode ?? "")
        callback?(add)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
extension AddressViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
extension AddressViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        resultSearchController?.searchBar.text = placemark.name
    }
}
