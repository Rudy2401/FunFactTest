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
let db = Firestore.firestore()

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            //            handleEvent(forRegion: region)
        }
    }
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

extension MainViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is open and in foregroud
        completionHandler(.alert)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // get the notification identifier to respond accordingly
        let identifier = response.notification.request.identifier
        print ("identifier = \(identifier)")
    }
}

extension MainViewController {
    
    func downloadLandmarks(caller: String) {
        if (mapViewRegionDidChangeFromUserInteraction() || caller == "viewDidLoad") {
            let spinner = showLoader(view: self.mapView)
            
            let client = Client(appID: "P1NWQ6JXG6", apiKey: "56f9249980860f38c01e52158800a9b0")
            let index = client.index(withName: "landmark_name")
            
            let mapRect = self.mapView.visibleMapRect
            let nwMapPoint = MKMapPoint(x: mapRect.origin.x, y: mapRect.maxY)
            let seMapPoint = MKMapPoint(x: mapRect.maxX, y: mapRect.origin.y)
            
            let query = Query()
            let boundingBox = GeoRect(p1: LatLng(lat: nwMapPoint.coordinate.latitude, lng: nwMapPoint.coordinate.longitude),
                                      p2: LatLng(lat: seMapPoint.coordinate.latitude, lng: seMapPoint.coordinate.longitude))
            if caller == "viewDidLoad" {
                query.aroundLatLng = LatLng(lat: self.mapView.userLocation.coordinate.latitude, lng: self.mapView.userLocation.coordinate.longitude)
                query.aroundRadius = .all
            } else {
                query.insideBoundingBox = [boundingBox]
            }

            var filters = ""
            for land in AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks {
                filters = filters + " NOT objectID:" + land.id + " AND "
            }
            if filters.count > 2 {
                query.filters = "(" + filters.dropLast(4) + ")"
            }
            
            index.search(query) { (res, error) in
                guard let hits = res!["hits"] as? [[String: AnyObject]] else { return }
                for hit in hits {
                    
                    let geoloc = hit["_geoloc"] as! [String: Double]
                    let coordinates = GeoPoint(latitude: geoloc["lat"]!, longitude: geoloc["lng"]!)
                    
                    let landmark = Landmark(id: hit["objectID"] as! String,
                                            name: hit["name"] as! String,
                                            address: hit["address"] as! String,
                                            city: hit["city"] as! String,
                                            state: hit["state"] as! String,
                                            zipcode: hit["zipcode"] as! String,
                                            country: hit["country"] as! String,
                                            type: hit["type"] as! String,
                                            coordinates: coordinates,
                                            image: hit["image"] as! String,
                                            numOfFunFacts: hit["numOfFunFacts"] as! Int,
                                            likes: hit["likes"] as! Int,
                                            dislikes: hit["dislikes"] as! Int)
                    
                    AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks.insert(landmark)
                    
                    // Add anotations
                    var annotation: FunFactAnnotation
                    annotation = FunFactAnnotation(landmarkID: hit["objectID"] as! String,
                                                   title: hit["name"] as! String,
                                                   address: "\(String(describing: hit["address"])), \(String(describing: hit["city"])), \(String(describing: hit["state"])), \(String(describing: hit["country"]))",
                                                    type: hit["type"] as! String,
                                                    coordinate: CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
                    self.mapView.addAnnotation(annotation)
                }
                spinner.dismissLoader()
            }
            
        }
    }
    
    func downloadFunFacts(for landmarkID: String, db: Firestore) {
        var funFacts = [FunFact]()
        db.collection("funFacts").whereField("landmarkId", isEqualTo: landmarkID).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var pageContent = Array<Any>()
                for document in querySnapshot!.documents {
                    let funFact = FunFact(landmarkId: document.data()["landmarkId"] as! String,
                                          id: document.data()["id"] as! String,
                                          description: document.data()["description"] as! String,
                                          likes: document.data()["likes"] as! Int,
                                          dislikes: document.data()["dislikes"] as! Int,
                                          verificationFlag: document.data()["verificationFlag"] as? String ?? "",
                                          image: document.data()["imageName"] as! String,
                                          imageCaption: document.data()["imageCaption"] as? String ?? "",
                                          disputeFlag: document.data()["disputeFlag"] as! String,
                                          submittedBy: document.data()["submittedBy"] as! String,
                                          dateSubmitted: document.data()["dateSubmitted"] as! String,
                                          source: document.data()["source"] as! String,
                                          tags: document.data()["tags"] as! [String])
                    pageContent.append(document.data()["id"] as! String)
                    AppDataSingleton.appDataSharedInstance.listOfFunFacts.listOfFunFacts.insert(funFact)
                    funFacts.append(funFact)
                }
                
                let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "funFactPage") as! FunFactPageViewController
                
                var address = ""
                for i in AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks {
                    if i.id == landmarkID {
                        address = i.address
                    }
                }
                destinationVC.pageContent = pageContent as NSArray
                destinationVC.funFacts = funFacts
                destinationVC.headingContent = self.landmarkTitle
                destinationVC.landmarkID = landmarkID
                destinationVC.landmarkType = self.landmarkType
                destinationVC.address = address
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        // customize your notification content
        let content = UNMutableNotificationContent()
        content.title = "Near " + region.identifier + "?"
        content.subtitle = "Did you know?"
        
        var tempLandmarkID = ""
        for landmark in AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks {
            if region.identifier == landmark.name {
                tempLandmarkID = landmark.id
                break
            }
        }
        for funFact in AppDataSingleton.appDataSharedInstance.listOfFunFacts.listOfFunFacts {
            if funFact.landmarkId == tempLandmarkID {
                content.body = funFact.description
                
                let imageName = "\(funFact.image).jpeg"
                let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
                if imageFromCache != nil {
                    let imageData = imageFromCache!.jpegData(compressionQuality: 1.0)
                    guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "\(funFact.image).jpeg", data: imageData! as NSData, options: nil) else { return  }
                    content.attachments = [attachment]
                    break
                } else {
                    let s = funFact.id
                    let imageName = "\(s).jpeg"
                    
                    let storage = Storage.storage()
                    let gsReference = storage.reference(forURL: "gs://funfacts-5b1a9.appspot.com/images/\(imageName)")
                    
                    gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error = \(error)")
                        } else {
                            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "\(funFact.image).jpeg", data: data! as NSData, options: nil) else { return  }
                            content.attachments = [attachment]
                        }
                    }
                    break
                }
            }
        }
        content.sound = UNNotificationSound.default
        notificationCount += 1
        
        // when the notification will be triggered
        let timeInSeconds: TimeInterval = (6) // 60s * 15 = 15min
        // the actual trigger object
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
                                                        repeats: false)
        
        // notification unique identifier, for this example, same as the region to avoid duplicate notifications
        let identifier = region.identifier
        
        // the notification request object
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        // trying to add the notification request to notification center
        notificationCenter?.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })
    }
}
