//
//  FirestoreConnection.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/19/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import MapKit
import FirebaseAuth

class FirestoreConnection {
    let db = Firestore.firestore()
    var listOfLandmarks: ListOfLandmarks?
    var listOfFunFacts: ListOfFunFacts?
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
    }
    func downloadFunFacts(completion: @escaping ([FunFact]?, Error?) -> Void) {
        db.collection("funFacts").getDocuments { (querySnapshot, err) in
            var listOfFunFacts = [FunFact]()
            if let err = err {
                print("Error getting documents: \(err)")
                completion(listOfFunFacts, err)
                return
            } else {
                for document in querySnapshot!.documents {
                    let funFact = FunFact(landmarkId: document.data()["landmarkId"] as! String,
                                          id: document.data()["id"] as! String,
                                          description: document.data()["description"] as! String,
                                          likes: document.data()["likes"] as! Int,
                                          dislikes: document.data()["dislikes"] as! Int,
                                          verificationFlag: document.data()["verificationFlag"] as! String,
                                          image: document.data()["imageName"] as! String,
                                          imageCaption: document.data()["imageCaption"] as! String,
                                          disputeFlag: document.data()["disputeFlag"] as! String,
                                          submittedBy: document.data()["submittedBy"] as! String,
                                          dateSubmitted: document.data()["dateSubmitted"] as! String,
                                          source: document.data()["source"] as! String,
                                          tags: document.data()["tags"] as! [String],
                                          approvalCount: document.data()["approvalCount"] as! Int,
                                          rejectionCount: document.data()["rejectionCount"] as! Int,
                                          approvalUsers: document.data()["approvalUsers"] as! [String],
                                          rejectionUsers: document.data()["rejectionUsers"] as! [String])
                    listOfFunFacts.append(funFact)
                }
                completion(listOfFunFacts, nil)
            }
        }
    }
    func createFunFactAnnotations(completion: @escaping ([FunFactAnnotation], Error?) -> Void) {
        db.collection("landmarks").getDocuments() { (querySnapshot, err) in
            var annotations = [FunFactAnnotation]()
            if let err = err {
                print("Error getting documents: \(err)")
                completion(annotations, err)
            } else {
                for document in querySnapshot!.documents {
                    var annotation: FunFactAnnotation
                    let coordinates =
                        CLLocationCoordinate2D(latitude: (document.data()["coordinates"] as! GeoPoint).latitude,
                                               longitude: (document.data()["coordinates"] as! GeoPoint).longitude)
                    annotation = FunFactAnnotation(landmarkID: document.data()["id"] as! String,
                                                   title: document.data()["name"] as! String,
                                                   address: "\(String(describing: document.data()["address"])), \(String(describing: document.data()["city"])), \(String(describing: document.data()["state"])), \(String(describing: document.data()["country"]))",
                        type: document.data()["type"] as! String,
                        coordinate: coordinates)
                    annotations.append(annotation)
                }
                completion(annotations, nil)
            }
        }
    }

    func downloadFunFactsIntoCache(_ completion: (_ listOfLandmarks: ListOfFunFacts?) -> Void) {
        db.collection("funFacts").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let funFact = FunFact(landmarkId: document.data()["landmarkId"] as! String,
                                          id: document.data()["id"] as! String,
                                          description: document.data()["description"] as! String,
                                          likes: document.data()["likes"] as! Int,
                                          dislikes: document.data()["dislikes"] as! Int,
                                          verificationFlag: document.data()["verificationFlag"] as! String,
                                          image: document.data()["imageName"] as! String,
                                          imageCaption: document.data()["imageCaption"] as! String,
                                          disputeFlag: document.data()["disputeFlag"] as! String,
                                          submittedBy: document.data()["submittedBy"] as! String,
                                          dateSubmitted: document.data()["dateSubmitted"] as! String,
                                          source: document.data()["source"] as! String,
                                          tags: document.data()["tags"] as! [String],
                                          approvalCount: document.data()["approvalCount"] as! Int,
                                          rejectionCount: document.data()["rejectionCount"] as! Int,
                                          approvalUsers: document.data()["approvalUsers"] as! [String],
                                          rejectionUsers: document.data()["rejectionUsers"] as! [String])
                    self.listOfFunFacts?.listOfFunFacts.insert(funFact)
                }
            }
        }
    }
    func downloadImagesIntoCache() {
        db.collection("funFacts").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let imageName = "\(document.data()["imageName"] ?? "").jpeg"
                    var image = UIImage()
                    let storage = Storage.storage()
                    let gsReference = storage.reference(forURL: "gs://funfacts-5b1a9.appspot.com/images/\(imageName)")
                    gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error = \(error)")
                        } else {
                            image = UIImage(data: data!)!
                            CacheManager.shared.cache(object: image, key: imageName)
                        }
                    }
                }
            }
        }
    }
    
    func addImageToCache(imageId: String) {
        let imageName = "\(imageId).jpeg"
        var image = UIImage()
        let storage = Storage.storage()
        let gsReference = storage.reference(forURL: "gs://funfacts-5b1a9.appspot.com/images/\(imageName)")
        gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error = \(error)")
            } else {
                image = UIImage(data: data!)!
                CacheManager.shared.cache(object: image, key: imageName)
            }
        }
    }
}
