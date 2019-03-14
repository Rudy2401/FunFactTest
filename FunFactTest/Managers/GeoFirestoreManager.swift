//
//  GeoFirestoreManager.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 3/5/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import Foundation
import Geofirestore
import FirebaseFirestore
import MapKit

protocol GeoFirestoreManagerDelegate: class {
    
}

class GeoFirestoreManager: FirestoreManagerDelegate {
    let geoFirestoreRef = Firestore.firestore().collection("landmarks")
    var geoFirestore: GeoFirestore?
    var delegate: GeoFirestoreManagerDelegate?
    var firestore = FirestoreManager()
    
    init() {
        geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        firestore.delegate = self
    }
    /// Retrieve all documents in the region specified
    func getLandmarks(by region: MKCoordinateRegion, completion: @escaping (Landmark?, String?, Int?) -> ()) {
        // MARK: Testing GeoFirestore
        let query = geoFirestore?.query(inRegion: region)
        var count = 0
        let _ = query?.observe(.documentEntered, with: { (key, location) in
            if let landmarkID = key {
                for id in AppDataSingleton.appDataSharedInstance.listOfLandmarkIDs {
                    if landmarkID == id {
                        completion(nil, FirestoreErrors.annotationExists, 0)
                        return
                    }
                }
                count += 1
                print ("count = \(count)")
                self.firestore.getLandmark(for: landmarkID, completion: { (landmark, error) in
                    if let error = error {
                        print ("Error getting landmark \(error)")
                        completion (nil, error, 0)
                    } else {
                        let landmark = landmark!
                        completion(landmark, nil, count)
                    }
                })
            }
        })
    }
    /// Retrieve all documents based on center and radius
    func getLandmarks(from center: CLLocation, radius: Double, completion: @escaping (Landmark?, String?, Int?) -> ()) {
        // MARK: Testing GeoFirestore
        if radius > 200 {
            completion(nil, FirestoreErrors.mapTooLarge, 0)
            return
        }
        let query = geoFirestore?.query(withCenter: center, radius: radius)
        var count = 0
        let _ = query?.observe(.documentEntered, with: { (key, location) in
            if let landmarkID = key {
                for id in AppDataSingleton.appDataSharedInstance.listOfLandmarkIDs {
                    if landmarkID == id {
                        completion(nil, FirestoreErrors.annotationExists, 0)
                        return
                    }
                }
                count += 1
                print ("count = \(count)")
                self.firestore.getLandmark(for: landmarkID, completion: { (landmark, error) in
                    if let error = error {
                        print ("Error getting landmark \(error)")
                        completion (nil, error, 0)
                    } else {
                        let landmark = landmark!
                        completion(landmark, nil, count)
                    }
                })
            }
        })
    }
    /// Add the Geofirestore related fields to /landmarks
    func addGeoFirestoreData(for documentID: String, coordinates: GeoPoint, completion: @escaping (String?) -> ()) {
        geoFirestore?.setLocation(geopoint: coordinates, forDocumentWithID: documentID) { (error) in
            if let error = error  {
                print("An error occured in GeoFirestore: \(error.localizedDescription)")
            } else {
                print("Saved location successfully!")
            }
        }
    }
    
    /// Retrieve all landmarks in an array that are in the region specified and sort them by likes desc
    func getLandmarks(in region: MKCoordinateRegion, completion: @escaping ([Landmark]?, String?) -> ()) {
        let collection = geoFirestoreRef.limit(to: 2)
        let query = geoFirestore?.query(inRegion: region)
        var landmarkIds = [String]()
        var count = 0
        let _ = query?.observe(.documentEntered, with: { (key, location) in
            if let landmarkID = key {
                for id in AppDataSingleton.appDataSharedInstance.listOfLandmarkIDs {
                    if landmarkID == id {
                        return
                    }
                }
                count += 1
                print ("count = \(count)")
                print ("landmarkID = \(landmarkID)")
                landmarkIds.append(landmarkID)
            }
        })
        query?.observeReady(withBlock: {
            print ("landmarkIds = \(landmarkIds)")
            self.firestore.getLandmarks(landmarkIds: landmarkIds, completion: { (landmarks, error) in
                if let error = error {
                    print ("Error getting all Landmarks \(error)")
                } else {
                    let newLandmarks = landmarks?.sorted(by: {$0.likes > $1.likes})
                    completion(newLandmarks, nil)
                }
            })
        })
    }
    func documentsDidUpdate() {
        
    }
    
}
