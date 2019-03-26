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
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
            let currentLocationCoordinate = location.coordinate
            self.currentLocationCoordinate = currentLocationCoordinate
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
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
    
    func downloadLandmarks(caller: Events) {
        let spinner = Utils.showLoader(view: self.mapView)
        mapView.removeAnnotations(mapView.annotations)
        
        let mapRect = self.mapView.visibleMapRect
        let nwMapPoint = MKMapPoint(x: mapRect.origin.x, y: mapRect.maxY)
        let seMapPoint = MKMapPoint(x: mapRect.maxX, y: mapRect.origin.y)
        
        let query = Query()
        
        let boundingBox = GeoRect(p1: LatLng(lat: nwMapPoint.coordinate.latitude,
                                             lng: nwMapPoint.coordinate.longitude),
                                  p2: LatLng(lat: seMapPoint.coordinate.latitude,
                                             lng: seMapPoint.coordinate.longitude))
        
        if caller == .firstLoad {
            query.aroundLatLng = LatLng(lat: self.mapView.userLocation.coordinate.latitude,
                                        lng: self.mapView.userLocation.coordinate.longitude)
            query.aroundRadius = .explicit(1000)
        } else {
            query.insideBoundingBox = [boundingBox]
        }
        let interests = UserDefaults.standard.array(forKey: "UserInterests")
        var filters = ""
        for interest in interests ?? [] {
            filters += "type:'\(interest)' OR "
        }
        filters = "\(filters.dropLast(4))"
        query.filters = filters
        
        query.hitsPerPage = 30
       
        var count = 0
        algoliaManager.downloadLandmarks(query: query) { (landmark, error) in
            if let error = error {
                if error == Errors.noRecordsFound.localizedDescription {
                    let alert = Utils.showAlert(status: .failure, message: ErrorMessages.noRecordsFound)
                    self.present(alert, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                            guard self?.presentedViewController == alert else { return }
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                print ("Error getting data from Algolia \(error)")
                spinner.dismissLoader()
            }
            else {
                let landmark = landmark!
                
                count += 1
                // Add anotations
                var annotation: FunFactAnnotation
                annotation = FunFactAnnotation(
                    landmarkID: landmark.id,
                    title: "\(count)) \(landmark.name)",
                    address: "\(landmark.address), \(landmark.city), \(landmark.state), \(landmark.country)",
                    type: landmark.type,
                    coordinate: CLLocationCoordinate2D(latitude: landmark.coordinates.latitude,
                                                       longitude: landmark.coordinates.longitude))
                self.mapView.addAnnotation(annotation)
                AppDataSingleton.appDataSharedInstance.listOfLandmarkIDs.append(landmark.id)
                spinner.dismissLoader()
            }
        }
    }
    
    func downloadFunFactsAndSegue(for landmarkID: String) {
        let spinner = Utils.showLoader(view: self.mapView)
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
