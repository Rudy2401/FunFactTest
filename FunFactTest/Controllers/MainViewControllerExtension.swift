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
let geofirestoreManager = GeoFirestoreManager()

extension MainViewController: CLLocationManagerDelegate, AlgoliaSearchManagerDelegate, GeoFirestoreManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        guard let location = manager.location else{
//            return
//        }
//        let currentLocationCoordinate = location.coordinate
//        self.currentLocationCoordinate = currentLocationCoordinate
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
            let currentLocationCoordinate = location.coordinate
            self.currentLocationCoordinate = currentLocationCoordinate
            // 4. setup Firestore data
            loadDataFromFirestoreAndAddAnnotations()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        downloadLandmarks(caller: .mapEvent)
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
    
    func downloadLandmarks(caller: FirestoreGeoConstants) {
        if (mapViewRegionDidChangeFromUserInteraction() || caller == .firstLoad) {
            // GeoFirestore Code
            let mapRect = self.mapView.visibleMapRect
            var center = CLLocation()
            
            var region = MKCoordinateRegion(mapRect)
            if caller == .firstLoad {
                center = CLLocation(latitude: currentLocationCoordinate.latitude,
                                    longitude: currentLocationCoordinate.longitude)
                region = MKCoordinateRegion(center: center.coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)
            }
            
            geofirestoreManager.getLandmarks(in: region) { (landmarks, error) in
                if let error = error {
                    if error == FirestoreErrors.annotationExists {
                    } else{
                        print ("Error getting data from GeoFirestore \(error)")
                    }
                }
                else {
                    if landmarks!.count > 20 {
                        print(FirestoreErrors.mapTooLarge)
                    } else {
                        let spinner = self.showLoader(view: self.mapView)
                        for landmark in landmarks! {
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
                            AppDataSingleton.appDataSharedInstance.listOfLandmarkIDs.append(landmark.id)
                        }
                        spinner.dismissLoader()
                    }
                }
            }
        }
    }
    
    func downloadFunFactsAndSegue(for landmarkID: String) {
        let spinner = showLoader(view: self.mapView)
        firestore.downloadFunFacts(for: landmarkID) { (funFacts, pageContent, error) in
            if let error = error {
                print("Error downloading Fun Facts \(error)")
            } else {
                let funFacts = funFacts!
                for funFact in funFacts {
                    if !CacheManager.shared.checkIfImageExists(imageName: "\(funFact.image).jpeg") {
                        self.firestore.uploadImageIntoCache(imageName: funFact.image)
                    }
                }
                let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "funFactPage") as! FunFactPageViewController
                destinationVC.pageContent = pageContent! as NSArray
                destinationVC.funFacts = funFacts
                destinationVC.headingContent = self.landmarkTitle
                destinationVC.landmarkID = landmarkID
                destinationVC.address = self.currentAnnotation?.address ?? ""
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
                spinner.dismissLoader()
            }
        }
    }
}
