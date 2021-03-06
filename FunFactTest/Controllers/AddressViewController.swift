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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBarAppearance()
            navBar.backgroundColor = Colors.systemGreenColor
            navBar.titleTextAttributes = Attributes.navTitleAttribute
            navBar.largeTitleTextAttributes = Attributes.navTitleAttribute
            self.navigationController?.navigationBar.standardAppearance = navBar
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBar
        } else {
            // Fallback on earlier versions
        }
        submitButton.backgroundColor = Colors.systemGreenColor
        mapView.bringSubviewToFront(submitButton)
        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
        
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable")
            as! LocationSearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        searchBar.becomeFirstResponder()
        textFieldInsideUISearchBar?.font = UIFont(name: Fonts.regularFont, size: 14.0)
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
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
        if selectedPin == nil {
            return
        }
        var streetAddress = ""
        if (selectedPin?.subThoroughfare == nil || selectedPin?.subThoroughfare == "") && (selectedPin?.thoroughfare == nil || selectedPin?.thoroughfare == "") {
            streetAddress = selectedPin!.name ?? ""
        } else {
            streetAddress = (selectedPin?.subThoroughfare ?? "") + " " + (selectedPin?.thoroughfare ?? "")
        }
        print (streetAddress)
        let add = AddressData(address: streetAddress,
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
