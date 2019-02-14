//
//  ContentViewControllerDataExtension.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/10/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

extension ContentViewController {
    func addLikes(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                // swiftlint:disable:next force_cast
                let likeCount = document.data()?["likes"] as! Int
                funFactRef.setData([
                    "likes": likeCount + 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error)")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                // swiftlint:disable:next force_cast
                let likeCount = document.data()?["likes"] as! Int
                db.collection("landmarks").document(self.landmarkID).setData([
                    "likes": likeCount + 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error.debugDescription)")
            }
        }
        db.collection("users").document(userID).collection("funFactsLiked").document(funFactID).setData([
            "funFactID": funFactRef
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    func addDislikes(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                funFactRef.setData([
                    "dislikes": dislikeCount + 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error)")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                db.collection("landmarks").document(self.landmarkID).setData([
                    "dislikes": dislikeCount + 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error.debugDescription)")
            }
        }
        db.collection("users").document(userID).collection("funFactsDisliked").document(funFactID).setData([
            "funFactID": funFactRef
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    func deleteLikes(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                let likeCount = document.data()?["likes"] as! Int // swiftlint:disable:this force_cast
                funFactRef.setData([
                    "likes": likeCount - 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error)")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["likes"] as! Int // swiftlint:disable:this force_cast
                db.collection("landmarks").document(self.landmarkID).setData([
                    "likes": dislikeCount - 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error.debugDescription)")
            }
        }
        db.collection("users").document(userID).collection("funFactsLiked").document(funFactID).delete()
    }
    func deleteDislikes(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                funFactRef.setData([
                    "dislikes": dislikeCount - 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error)")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                db.collection("landmarks").document(self.landmarkID).setData([
                    "dislikes": dislikeCount - 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error.debugDescription)")
            }
        }
        db.collection("users").document(userID).collection("funFactsDisliked").document(funFactID).delete()
    }
    func setupImage() {
        let imageId = funFactID
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            print("******In cache")
            self.landmarkImage.image = imageFromCache
            self.landmarkImage.layer.cornerRadius = 5
        } else {
            let imageName = "\(funFactID).jpeg"
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            self.landmarkImage.sd_setImage(with: gsReference, placeholderImage: UIImage())
            self.landmarkImage.layer.cornerRadius = 5
        }
    }
}
