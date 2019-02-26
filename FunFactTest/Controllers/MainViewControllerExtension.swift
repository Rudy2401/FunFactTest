//
//  NotificationController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 12/13/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation
import FirebaseFirestore
import FirebaseStorage
import InstantSearch
import MapKit

var mapChangedFromUserInteraction = false
let algoliaManager = AlgoliaSearchManager()

extension MainViewController: CLLocationManagerDelegate, AlgoliaSearchManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else{
            return
        }
        let currentLocationCoordinate = location.coordinate
        self.currentLocationCoordinate = currentLocationCoordinate
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        downloadLandmarks(caller: "event")
    }

    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        return self.mapView.subviews.first?.gestureRecognizers?
            .contains(where: {
                $0.state == .began || $0.state == .ended
            }) == true
    }
    func documentsDidDownload() {
        
    }
}
extension UNNotificationAttachment {
    
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
            try data.write(to: fileURL!, options: [])
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL!, options: options)
            return imageAttachment
        } catch let error {
            print("error \(error)")
        }
        return nil
    }
}

extension MainViewController {
    
    func downloadLandmarks(caller: String) {
        if (mapViewRegionDidChangeFromUserInteraction() || caller == "viewDidLoad") {
            let spinner = showLoader(view: self.mapView)
            
            let mapRect = self.mapView.visibleMapRect
            let nwMapPoint = MKMapPoint(x: mapRect.origin.x, y: mapRect.maxY)
            let seMapPoint = MKMapPoint(x: mapRect.maxX, y: mapRect.origin.y)
            
            let query = Query()
            let boundingBox = GeoRect(p1: LatLng(lat: nwMapPoint.coordinate.latitude,
                                                 lng: nwMapPoint.coordinate.longitude),
                                      p2: LatLng(lat: seMapPoint.coordinate.latitude,
                                                 lng: seMapPoint.coordinate.longitude))
            if caller == "viewDidLoad" {
                query.aroundLatLng = LatLng(lat: self.mapView.userLocation.coordinate.latitude,
                                            lng: self.mapView.userLocation.coordinate.longitude)
                query.aroundRadius = .all
            } else {
                query.insideBoundingBox = [boundingBox]
            }
            
            var filters = ""
            if caller != "viewDidLoad" {
                for annotation in mapView.annotations {
                    if annotation is MKUserLocation {
                        print ("MKUserLocation")
                    } else {
                        let a = annotation as! FunFactAnnotation
                        filters = filters + " NOT objectID:" + a.landmarkID + " AND "
                    }
                }
                if filters.count > 2 {
                    query.filters = "(" + filters.dropLast(4) + ")"
                }
            }
            
            algoliaManager.downloadLandmarks(query: query) { (landmark, error) in
                if let error = error {
                    print ("Error getting data from Algolia \(error)")
                }
                else {
                    let landmark = landmark!
                    self.setupGeoFences(lat: landmark.coordinates.latitude,
                                        lon: landmark.coordinates.longitude,
                                        title: landmark.name,
                                        landmarkID: landmark.id)
                    
                    // Add anotations
                    var annotation: FunFactAnnotation
                    annotation = FunFactAnnotation(
                        landmarkID: landmark.id,
                        title: landmark.name,
                        address: "\(landmark.address), \(landmark.city), \(landmark.state), \(landmark.country)",
                        type: landmark.type,
                        coordinate: CLLocationCoordinate2D(latitude: landmark.coordinates.latitude,
                                                           longitude: landmark.coordinates.longitude))
                    self.mapView.addAnnotation(annotation)
                    spinner.dismissLoader()
                }
            }
        }
    }
    
    func downloadFunFactsAndSegue(for landmarkID: String, db: Firestore) {
        let spinner = showLoader(view: self.mapView)
        firestore.downloadFunFacts(for: landmarkID) { (funFacts, pageContent, error) in
            if let error = error {
                print("Error downloading Fun Facts \(error)")
            } else {
                let funFacts = funFacts!
                let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "funFactPage") as! FunFactPageViewController
                destinationVC.pageContent = pageContent! as NSArray
                destinationVC.funFacts = funFacts
                destinationVC.headingContent = self.landmarkTitle
                destinationVC.landmarkID = landmarkID
                destinationVC.landmarkType = self.landmarkType
                destinationVC.address = self.currentAnnotation?.address ?? ""
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
                spinner.dismissLoader()
            }
        }
    }
}
