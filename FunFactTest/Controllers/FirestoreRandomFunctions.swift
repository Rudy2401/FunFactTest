//
//  FirestoreRandomFunctions.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/5/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import Geofirestore

extension MainViewController {
    func updateData() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    var description = document.data()["description"] as! String
                    let tags = document.data()["tags"] as! [String]
                    for tag in tags {
                        description.append(" #\(tag)")
                    }
                    
                    db.collection("funFacts").document(document.data()["id"] as! String).setData(["description": description], merge: true)
                }
            }
        }
    }
    func updateTags() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.data()["id"] as! String
                    let tags = document.data()["tags"] as! [String]
                    let funFactRef = db.collection("funFacts").document(id)
                    for tag in tags {
                        db.collection("hashtags").document(tag).collection("funFacts").document(id).setData(["funFactID": funFactRef], merge: true)
                    }
                }
            }
        }
    }
    
    func updateUsers() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.data()["id"] as! String
                    let user = document.data()["submittedBy"] as! String
                    let funFactRef = db.collection("funFacts").document(id)
                    db.collection("users")
                        .document(user)
                        .collection("funFactsSubmitted")
                        .document(id)
                        .setData(["funFactID": funFactRef],
                                 merge: true)
                }
            }
        }
    }
    func updateUsersDisputes() {
        let db = Firestore.firestore()
        db.collection("disputes").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.data()["disputeID"] as! String
                    let user = document.data()["user"] as! String
                    let disputeRef = db.collection("disputes").document(id)
                    
                    db.collection("users")
                        .document(user)
                        .collection("funFactsDisputed")
                        .document(id)
                        .setData(["disputeID": disputeRef],
                                 merge: true)
                    
                }
            }
        }
    }
    func updateLikesDislikes() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let funFactId = document.data()["id"] as! String
                    db.collection("funFacts").document(funFactId).setData(["likes": 0], merge: true)
                    db.collection("funFacts").document(funFactId).setData(["dislikes": 0], merge: true)
                }
            }
        }
    }
    
    func updateUserCounts() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            var userCount = [String: Int]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let user = document.data()["submittedBy"] as! String
                    userCount[user] = (userCount[user] ?? 0) + 1
                }
                print ("userCount = \(userCount)")
                for user in userCount.keys {
                    db.collection("users").document(user).setData(["submittedCount": userCount[user]!], merge: true)
                }
            }
        }
    }
    
    func deleteTags() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let description = document.data()["description"] as! String
                    let onlyDesc = description.components(separatedBy: "#")[0]
                    
                    db.collection("funFacts").document(document.data()["id"] as! String).setData(["description": onlyDesc], merge: true)
                }
            }
        }
    }
    
    func renameAndDeleteLandmarks() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let funFactID = document.documentID
                    let data = ["id": funFactID]
                    db.collection("funFacts").document(funFactID).setData(data, merge: true)
                }
            }
        }
    }
    func updateImageMetadata() {
        // Create reference to the file whose metadata we want to change
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let imageName = document.data()["imageName"] as! String
                    let imageRef = storageRef.child("images/\(imageName).jpeg")
                    
                    // Create file metadata to update
                    let newMetadata = StorageMetadata()
                    newMetadata.cacheControl = "public,max-age=300"
                    newMetadata.contentType = "image/jpeg"
                    
                    // Update metadata properties
                    imageRef.updateMetadata(newMetadata) { metadata, error in
                        if let error = error {
                            print (error)
                        } else {
                            // Updated metadata for 'images/forest.jpg' is returned
                        }
                    }
                }
            }
        }
    }
    func addLotOfStuff() {
//        let la = FunFact(landmarkId: "land",
//                         id: "qwe",
//                         description: "qwerty",
//                         likes: 0, dislikes: 0,
//                         verificationFlag: "Y",
//                         image: "QWE",
//                         imageCaption: "zc",
//                         disputeFlag: "N",
//                         submittedBy: "asdfc",
//                         dateSubmitted: "asd",
//                         source: "asd",
//                         tags: ["qwerty"])
//        
//        for _ in 0...1000000 {
//            AppDataSingleton.appDataSharedInstance.listOfFunFacts.listOfFunFacts.insert(la)
//        }
    }
    func addVerificationFields() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let funFactID = document.documentID
                    let data = ["rejectionReason": []] as [String : Any]
                    db.collection("funFacts").document(funFactID).setData(data, merge: true)
                }
            }
        }
    }
    func convertStringToTimestamp() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments { (snap, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snap!.documents {
                    let funFactID = document.documentID
                    let dateString = document.data()["dateSubmitted"] as! String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd, yyyy"
                    let date = dateFormatter.date(from: dateString)
                    let dateSubmitted = Timestamp(date: date!)
                    
                    let data = ["dateSubmitted": dateSubmitted]
                    
                    db.collection("funFacts").document(funFactID).setData(data, merge: true)
                }
            }
        }
    }
    func addLandmarkNameToFunFacts() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    let landmarkID = document.data()["landmarkId"] as! String
                    let funFactID = document.documentID as String
                    db.collection("landmarks")
                        .document(landmarkID)
                        .getDocument(completion: { (snapshot, error) in
                            if let error = error {
                                print("Error getting documents: \(error)")
                            } else {
                                let landmarkName = snapshot?.data()?["name"] as! String
                                db.collection("funFacts")
                                    .document(funFactID)
                                    .setData(["landmarkName": landmarkName], merge: true)
                            }
                    })
                }
            }
        }
    }
    func updateGeoFirestoreData() {
        let db = Firestore.firestore()
        let geoFirestoreRef = Firestore.firestore().collection("landmarks")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        db.collection("landmarks").getDocuments { (snap, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in (snap?.documents)! {
                    let coordinates = doc.data()["coordinates"] as! GeoPoint
                    geoFirestore.setLocation(geopoint: coordinates, forDocumentWithID: doc.documentID) { (error) in
                        if (error != nil) {
                            print("An error occured: \(error)")
                        } else {
                            print("Saved location successfully!")
                        }
                    }
                }
            }
        }
    }
    func removeLatLong() {
        let db = Firestore.firestore()
        db.collection("landmarks").getDocuments { (snap, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in (snap?.documents)! {
                    let documentID = doc.documentID
                    db.collection("landmarks")
                        .document(documentID)
                        .updateData(["latitude": FieldValue.delete(),
                                     "longitude": FieldValue.delete()]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                        } else {
                                            print("Document successfully updated")
                                        }
                    }
                }
            }
        }
    }
    func addLandmarkNameCollection() {
        let db = Firestore.firestore()
        db.collection("landmarks").getDocuments { (snap, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in (snap?.documents)! {
                    let landmarkName = doc.data()["name"] as! String
                    let landmarkID = doc.documentID
                    db.collection("landmarkNames").document(landmarkName).setData(["id": landmarkID], merge: true) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Collection successfully updated")
                        }
                    }
                }
            }
        }
    }
    func addFunFactTitle() {
        let db = Firestore.firestore()
        db.collection("funFacts").getDocuments { (snap, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in (snap?.documents)! {
                    let funFactID = doc.documentID as String
                    db.collection("funFacts").document(funFactID).setData(["funFactTitle": ""], merge: true)
                }
            }
        }
    }
    func checkIntegrity() {
        let db = Firestore.firestore()
        var count = 0
        db.collection("landmarks").getDocuments { (snap, error) in
            for _ in snap!.documents {
                count += 1
            }
            print ("Number of landmarks = \(count)")
        }
        db.collection("funFacts").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in snapshot!.documents {
                    let landmarkID = doc.data()["landmarkId"] as? String
                    db.collection("landmarks").document(landmarkID!).getDocument(completion: { (snap, error) in
                        if let error = error {
                            print ("Document: \(landmarkID!) not found. Error: \(error.localizedDescription)")
                        } else {
                            print ("All Good!")
                        }
                    })
                }
            }
        }
        
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in snapshot!.documents {
                    let userID = doc.data()["uid"] as? String
                    db.collection("users").document(userID!).collection("funFactsRejected").getDocuments(completion: { (snap, error) in
                        if let error = error {
                            print ("Error getting sub collections: \(error.localizedDescription)")
                        } else {
                            for doc in snap!.documents {
                                let ref = doc.data()["funFactID"] as! DocumentReference
                                ref.getDocument(completion: { (snap, error) in
                                    if let error = error {
                                        print ("Error getting reference: \(error.localizedDescription)")
                                    } else {
                                        print ("All Good!!")
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    func replaceUserRefsWithFunFacts() {
        let collections = ["funFactsDisliked", "funFactsLiked", "funFactsSubmitted", "funFactsDisputed", "funFactsVerified", "funFactsRejected"]
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snap, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in snap!.documents {
                    let userID = doc.documentID
                    for collection in collections {
                        db.collection("users").document(userID).collection(collection).getDocuments(completion: { (nestedsnap, error) in
                            if let error = error {
                                print ("Error getting nested document \(error)")
                            } else {
                                for nesteddoc in nestedsnap!.documents {
                                    let funFactID = nesteddoc.documentID
                                    self.firestore.downloadFunFact(for: funFactID, completionHandler: { (funFact, error) in
                                        if let error = error {
                                            print ("Error getting nested funFact \(error)")
                                        } else {
                                            print (funFactID)
                                            let funFact = funFact!
                                            db.collection("users")
                                                .document(userID)
                                                .collection(collection)
                                                .document(funFactID)
                                                .setData(["landmarkName": funFact.landmarkName,
                                                          "id": funFact.id,
                                                          "description": funFact.description])
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    func replaceHashtagsWithFunFacts() {
        let db = Firestore.firestore()
        db.collection("hashtags").getDocuments { (snap, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in snap!.documents {
                    let hashtagID = doc.documentID
                    db.collection("hashtags").document(hashtagID).collection("funFacts").getDocuments(completion: { (nestedsnap, error) in
                        if let error = error {
                            print ("Error getting nested document \(error)")
                        } else {
                            for nesteddoc in nestedsnap!.documents {
                                let funFactID = nesteddoc.documentID
                                self.firestore.downloadFunFact(for: funFactID, completionHandler: { (funFact, error) in
                                    if let error = error {
                                        print ("Error getting nested funFact \(error)")
                                    } else {
                                        print (funFactID)
                                        let funFact = funFact!
                                        db.collection("hashtags")
                                            .document(hashtagID)
                                            .collection("funFacts")
                                            .document(funFactID)
                                            .setData(["landmarkName": funFact.landmarkName,
                                                      "id": funFact.id,
                                                      "description": funFact.description])
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
    }
}
