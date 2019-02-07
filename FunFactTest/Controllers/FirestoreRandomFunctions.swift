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
                    
                    db.collection("users").document(user).collection("funFactsSubmitted").document(id).setData(["funFactID": funFactRef], merge: true)
                    
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
                    
                    db.collection("users").document(user).collection("funFactsDisputed").document(id).setData(["disputeID": disputeRef], merge: true)
                    
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
        let la = FunFact(landmarkId: "land", id: "qwe", description: "qwerty", likes: 0, dislikes: 0, verificationFlag: "Y", image: "QWE", imageCaption: "zc", disputeFlag: "N", submittedBy: "asdfc", dateSubmitted: "asd", source: "asd", tags: ["qwerty"])
        
        for _ in 0...1000000 {
            AppDataSingleton.appDataSharedInstance.listOfFunFacts.listOfFunFacts.insert(la)
        }
    }
}
