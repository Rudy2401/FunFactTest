//
//  FirestoreConnection.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/19/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreLocation

protocol FirestoreManagerDelegate: class {
    func documentsDidUpdate()
}

class FirestoreManager {
    lazy var db = Firestore.firestore()
    var delegate: FirestoreManagerDelegate?
    var storage: Storage!

    init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        storage = Storage()
    }

    func uploadImageIntoCache(imageName: String) {
        let imageName = "\(imageName).jpeg"
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

    
    /// Downloads fun fact data from firestore for a fuc fact reference
    func downloadFunFacts(for ref: DocumentReference, completionHandler: @escaping (FunFact) -> ())  {
        ref.getDocument { (snapshot, error) in
            if let document = snapshot, document.exists {
                let funFact = FunFact(landmarkId: document.data()?["landmarkId"] as! String,
                                      landmarkName: document.data()?["landmarkName"] as! String,
                                      id: document.data()?["id"] as! String,
                                      description: document.data()?["description"] as! String,
                                      likes: document.data()?["likes"] as! Int,
                                      dislikes: document.data()?["dislikes"] as! Int,
                                      verificationFlag: document.data()?["verificationFlag"] as? String ?? "",
                                      image: document.data()?["imageName"] as! String,
                                      imageCaption: document.data()?["imageCaption"] as? String ?? "",
                                      disputeFlag: document.data()?["disputeFlag"] as! String,
                                      submittedBy: document.data()?["submittedBy"] as! String,
                                      dateSubmitted: document.data()?["dateSubmitted"] as! Timestamp,
                                      source: document.data()?["source"] as! String,
                                      tags: document.data()?["tags"] as! [String],
                                      approvalCount: document.data()?["approvalCount"] as! Int,
                                      rejectionCount: document.data()?["rejectionCount"] as! Int,
                                      approvalUsers: document.data()?["approvalUsers"] as! [String],
                                      rejectionUsers: document.data()?["rejectionUsers"] as! [String],
                                      rejectionReason: document.data()?["rejectionReason"] as! [String])
                completionHandler(funFact)
            } else {
                print("Document \(ref.documentID) does not exist")
            }
        }
    }
    
    /// Downloads hashtag and count into a dictionary
    func downloadHashtags(completionHandler: @escaping ([String: Int]) -> Void) {
        var hashtags = [String: Int]()
        db.collection("hashtags").getDocuments { (snap, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for doc in snap!.documents {
                    hashtags[doc.documentID] = doc.data()["hashtagcount"] as? Int
                }
            }
            completionHandler(hashtags)
        }
    }
    /// Upload Hashtags to the /hashtags collection
    func addHashtags(funFactID: String, hashtags: [String]) {
        let funFactRef = db.collection("funFacts").document(funFactID)
        
        for hashtag in hashtags {
            db.collection("hashtags").document(hashtag).collection("funFacts").document(funFactID).setData([
                "funFactID": funFactRef
            ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    /// Add reference to collection /users/{userID}/funFactsSubmitted/{funFactID}
    func addUserSubmitted(funFactID: String, userID: String) {
        let funFactRef = db.collection("funFacts").document(funFactID)
        
        db.collection("users").document(userID).collection("funFactsSubmitted").document(funFactID).setData([
            "funFactID": funFactRef
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    /// Add reference to collection /users/{userID}/funFactsVerified/{funFactID}
    func addFunFactVerifiedToUser(funFactRef: DocumentReference, funFactID: String, user: String) {
        db.collection("users")
            .document(user)
            .collection("funFactsVerified")
            .document(funFactID)
            .setData(["funFactID": funFactRef],
                     merge: true) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
        }
    }
    /// Add reference to collection /users/{userID}/funFactsRejected/{funFactID}
    func addFunFactRejectedToUser(funFactRef: DocumentReference, funFactID: String, user: String) {
        db.collection("users")
            .document(user)
            .collection("funFactsRejected")
            .document(funFactID)
            .setData(["funFactID": funFactRef],
                     merge: true) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
        }
    }
    /// Upload image to Firebase storage
    func uploadImage(imageName: String, image: UIImage, type: String, completion: @escaping (URL?, String?) -> ()) {
        var data = Data()
        // Create a storage reference from our storage service
        let storageRef = Storage.storage().reference()
        // Data in memory
        
        do {
            try image.compressImage(300, completion: { (image, compressRatio) in
                print(image.size)
                data = image.jpegData(compressionQuality: compressRatio)!
            })
        } catch {
            print("Error")
        }
        
        // Create a reference to the file you want to upload
        var basePath = ""
        switch type {
        case ImageType.profile:
            basePath = ImageType.profile
        case ImageType.funFact:
            basePath = ImageType.funFact
        default:
            basePath = ImageType.funFact
        }
        let landmarkRef = storageRef.child("\(basePath)/\(imageName)")
        let metadata = StorageMetadata()
        // Metadata contains file metadata such as size, content-type.
        metadata.contentType = "image/jpeg"
        metadata.cacheControl = "public,max-age=300"
        landmarkRef.putData(data,
                            metadata: metadata,
                            completion: { (_, error) in
                                if let error = error {
                                    completion(nil, error.localizedDescription)
                                } else {
                                    landmarkRef.downloadURL { (url, error) in
                                        if let error = error {
                                            completion(nil, error.localizedDescription)
                                        } else {
                                            let url = url
                                            completion(url, nil)
                                        }
                                    }
                                }
        })
        
        
    }
    /// Goes through entire list of /landmarks and checks if landmark added already exists in the database. If it exists, fun fact is added to existing landmark
    func checkIfLandmarkExists(address: String, completionHandler: @escaping (String, Int, Int, Int) -> Void) {
        var landmarkID = ""
        var numOfFunFacts = 0
        var likes = 0
        var dislikes = 0
        db.collection("landmarks").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    let addr = ((document.data()["address"] as! String)
                        + (document.data()["city"] as! String)
                        + (document.data()["state"] as! String)
                        + (document.data()["country"] as! String)
                        + (document.data()["zipcode"] as! String)).lowercased()
                    if addr == address {
                        landmarkID = document.data()["id"] as! String
                        numOfFunFacts = document.data()["numOfFunFacts"] as! Int
                        likes = document.data()["likes"] as! Int
                        dislikes = document.data()["dislikes"] as! Int
                        completionHandler(landmarkID, numOfFunFacts, likes, dislikes)
                    } else {
                        completionHandler(landmarkID, numOfFunFacts, likes, dislikes)
                    }
                }
            }
        }
    }
    /// When user clicks on Approve button during verification - verificationFlag, approvalCount and approvalUsers are updated
    func updateVerificationFlag(for funFactID: String, verFlag: String, apprCount: Int, completion: @escaping (String) -> Void) {
        db.collection("funFacts")
            .document(funFactID)
            .setData(["verificationFlag": verFlag,
                      "approvalCount": apprCount,
                      "approvalUsers": FieldValue.arrayUnion([Auth.auth().currentUser?.uid ?? ""])],
                     merge: true) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            completion("fail")
                        } else {
                            print("Document successfully written!")
                            completion("success")
                        }
        }
    }
    /// When user clicks on Reject button during verification - verificationFlag, rejectionCount, reason and rejectionUsers are updated
    func updateRejectionFlag(for funFactID: String, verFlag: String, rejCount: Int, reason: String, completion: @escaping (String) -> Void) {
        db.collection("funFacts")
            .document(funFactID)
            .setData(["verificationFlag": verFlag,
                      "rejectionCount": rejCount,
                      "rejectionUsers": FieldValue.arrayUnion([Auth.auth().currentUser?.uid ?? ""]),
                      "rejectionReason": FieldValue.arrayUnion([reason as Any])],
                     merge: true) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            completion("fail")
                        } else {
                            print("Document successfully written!")
                            completion("success")
                        }
        }
    }
    
    /// Does 3 things:
    /// 1. Updates likes in /funFacts
    /// 2. Updates likes in /landmarks
    /// 3. Adds funFactRef to /users/{userID}/funFactsLiked/{funFactID}
    func addLikes(funFactID: String, landmarkID: String, userID: String) {
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
                print ("Error getting document \(String(describing: error?.localizedDescription))")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                // swiftlint:disable:next force_cast
                let likeCount = document.data()?["likes"] as! Int
                db.collection("landmarks").document(landmarkID).setData([
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
    /// Does 3 things:
    /// 1. Updates dislikes in /funFacts
    /// 2. Updates dislikes in /landmarks
    /// 3. Adds funFactRef to /users/{userID}/funFactsDisliked/{funFactID}
    func addDislikes(funFactID: String, landmarkID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int
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
                let error = error
                print ("Error getting document \(String(describing: error))")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int
                db.collection("landmarks").document(landmarkID).setData([
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
    /// When user clicks dislike button while like button is pressed or when user clicks like button when like button is pressed, likes is reduced by 1
    func deleteLikes(funFactID: String, landmarkID: String, userID: String) {
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
                print ("Error getting document \(String(describing: error?.localizedDescription))")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["likes"] as! Int // swiftlint:disable:this force_cast
                db.collection("landmarks").document(landmarkID).setData([
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
    /// When user clicks like button while dislike button is pressed or when user clicks dislike button when dislike button is pressed, dislikes is reduced by 1
    func deleteDislikes(funFactID: String, landmarkID: String, userID: String) {
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
                print ("Error getting document \(String(describing: error?.localizedDescription))")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                db.collection("landmarks").document(landmarkID).setData([
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
    /// Downloads user profile into the UserProfile object
    func downloadUserProfile(_ uid: String, completionHandler: @escaping (UserProfile) -> ())  {
        if uid == "" {
            return
        }
        var user = UserProfile(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, verifiedCount: 0, rejectedCount: 0, email: "", name: "", userName: "", level: "", photoURL: "", provider: "",city: "", country: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [], funFactsVerified: [], funFactsRejected: [])
        db.collection("users").document(uid).getDocument { (snapshot, error) in
            if let document = snapshot {
                user.dislikeCount = document.data()?["dislikeCount"] as! Int
                user.likeCount = document.data()?["likeCount"] as! Int
                user.disputeCount = document.data()?["disputeCount"] as! Int
                user.submittedCount = document.data()?["submittedCount"] as! Int
                user.email = document.data()?["email"] as! String
                user.name = document.data()?["name"] as! String
                user.level = document.data()?["level"] as! String
                user.photoURL = document.data()?["photoURL"] as! String
                user.provider = document.data()?["provider"] as! String
                user.uid = document.data()?["uid"] as! String
                user.userName = document.data()?["userName"] as! String
                user.city = document.data()?["city"] as! String
                user.country = document.data()?["country"] as! String
                user.verifiedCount = document.data()?["verifiedCount"] as! Int
                user.rejectedCount = document.data()?["rejectedCount"] as! Int
                
                completionHandler(user)
            }
            else {
                let err = error
                print("Error getting documents: \(String(describing: err))")
            }
        }
    }
    /// Downloads user submitted, verified, disputed, liked and disliked data
    func downloadOtherUserData(_ uid: String, collection: String, completionHandler: @escaping ([DocumentReference]) -> ()) {
        var refs = [DocumentReference]()
        db.collection("users").document(uid).collection(collection).getDocuments() { (snap, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for doc in snap!.documents {
                    if collection == "funFactsDisputed" {
                        refs.append(doc.data()["disputeID"] as! DocumentReference)
                    } else {
                        refs.append(doc.data()["funFactID"] as! DocumentReference)
                    }
                }
            }
            completionHandler(refs)
        }
    }
    /// Updates the firestore collection /users with additional user data
    func updateUserAdditionalFields(for user: User) {
        let db = Firestore.firestore()
        let randomNumber = arc4random()
        db.collection("users")
            .document(user.uid)
            .setData(["uid": user.uid,
                      "dislikeCount": 0,
                      "disputeCount": 0,
                      "likeCount": 0,
                      "level": UserLevel.rookie,
                      "submittedCount": 0,
                      "verifiedCount": 0,
                      "rejectedCount": 0,
                      "email": user.email ?? "",
                      "name": user.displayName ?? "",
                      "userName": "user" + String(randomNumber),
                      "photoURL": user.photoURL ?? "",
                      "provider": user.providerID],
                     merge: true) { (error) in
                        if let error = error {
                            print ("Error creating document \(error)")
                        }
        }
    }
    /// Adds Dispute details to /disputes
    func addDispute(for disputeID: String, funFactID: String, reason: String, description: String, user: String, date: Timestamp, completion: @escaping (String?) -> ()) {
        db.collection("disputes").document(disputeID).setData([
            "disputeID": disputeID,
            "funFactID": funFactID,
            "reason": reason,
            "description": description,
            "user": user,
            "dateSubmitted": date
        ]){ err in
            if let err = err {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }
    /// Adds dispute reference to /users/{userID}/funFactsDisputed/{disputeID}
    func addUserDisputes(disputeID: String, userID: String) {
        let disputeRef = db.collection("disputes").document(disputeID)
        
        db.collection("users").document(userID).collection("funFactsDisputed").document(disputeID).setData([
            "disputeID": disputeRef
        ], merge: true){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    /// Updates dispute flag in /funFacts
    func updateDisputeFlag(funFactID: String) {
        let disputeRef = db.collection("funFacts").document(funFactID)
        disputeRef.updateData([
            "disputeFlag": "Y"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    /// Add/Edit a Landmark to /landmark/{landmarkID}
    func addLandmark(landmark: Landmark, completion: @escaping (String?) -> ()) {
        db.collection("landmarks").document(landmark.id).setData([
            "id": landmark.id,
            "name": landmark.name,
            "address": landmark.address,
            "city": landmark.city,
            "state": landmark.state,
            "zipcode": landmark.zipcode,
            "country": landmark.country,
            "image": landmark.image,
            "type": landmark.type,
            "numOfFunFacts": landmark.numOfFunFacts,
            "likes": landmark.likes,
            "dislikes": landmark.dislikes,
            "coordinates": GeoPoint(latitude: landmark.coordinates.latitude as Double,
                                    longitude: landmark.coordinates.longitude as Double)
        ], merge: true) { err in
            if let error = err {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Add/Edit Fun fact to /funFacts/{funFactID}
    func addFunFact(funFact: FunFact, completion: @escaping (String?) -> ()) {
        db.collection("funFacts").document(funFact.id).setData([
            "landmarkId": funFact.landmarkId,
            "landmarkName": funFact.landmarkName,
            "id": funFact.id,
            "description": funFact.description,
            "likes": funFact.likes,
            "dislikes": funFact.dislikes,
            "verificationFlag": funFact.verificationFlag,
            "imageName": funFact.id,
            "disputeFlag": funFact.disputeFlag,
            "submittedBy": Auth.auth().currentUser?.uid ?? "",
            "dateSubmitted": funFact.dateSubmitted,
            "imageCaption": funFact.imageCaption,
            "source": funFact.source,
            "tags": funFact.tags,
            "approvalCount": funFact.approvalCount,
            "approvalUsers": funFact.approvalUsers,
            "rejectionCount": funFact.rejectionCount,
            "rejectionUsers": funFact.rejectionUsers,
            "rejectionReason": funFact.rejectionReason
        ], merge: true) { err in
            if let err = err {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Get landmark object for a landmarkID
    func getLandmark(for landmarkID: String, completion: @escaping (Landmark?, String?) -> ()) {
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                let document = snapshot!
                let landmark = Landmark(id: document.data()?["id"] as! String,
                                        name: document.data()?["name"] as! String,
                                        address: document.data()?["address"] as! String,
                                        city: document.data()?["city"] as! String,
                                        state: document.data()?["state"] as! String,
                                        zipcode: document.data()?["zipcode"] as! String,
                                        country: document.data()?["country"] as! String,
                                        type: document.data()?["type"] as! String,
                                        coordinates: document.data()?["coordinates"] as! GeoPoint,
                                        image: document.data()?["image"] as! String,
                                        numOfFunFacts: document.data()?["numOfFunFacts"] as! Int,
                                        likes: document.data()?["likes"] as! Int,
                                        dislikes: document.data()?["dislikes"] as! Int)
                completion(landmark, nil)
            }
        }
    }
    
    /// Download Fun facts sorted based on verification flag desc and likes desc
    /// - Parameters:
    ///     - landmarkID: Landmark document name
    ///     - completion: All fun facts for the landmarkID
    func downloadFunFacts(for landmarkID: String, completion: @escaping ([FunFact]?, [Any]?, String?) -> ()) {
        var funFacts = [FunFact]()
        db.collection("funFacts")
            .whereField("landmarkId", isEqualTo: landmarkID)
            .order(by: "verificationFlag", descending: true)
            .order(by: "likes", descending: true)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    completion(nil, nil, err.localizedDescription)
                } else {
                    var pageContent = Array<Any>()
                    for document in querySnapshot!.documents {
                        let funFact = FunFact(landmarkId: document.data()["landmarkId"] as! String,
                                              landmarkName: document.data()["landmarkName"] as! String,
                                              id: document.data()["id"] as! String,
                                              description: document.data()["description"] as! String,
                                              likes: document.data()["likes"] as! Int,
                                              dislikes: document.data()["dislikes"] as! Int,
                                              verificationFlag: document.data()["verificationFlag"] as? String ?? "",
                                              image: document.data()["imageName"] as! String,
                                              imageCaption: document.data()["imageCaption"] as? String ?? "",
                                              disputeFlag: document.data()["disputeFlag"] as! String,
                                              submittedBy: document.data()["submittedBy"] as! String,
                                              dateSubmitted: document.data()["dateSubmitted"] as! Timestamp,
                                              source: document.data()["source"] as! String,
                                              tags: document.data()["tags"] as! [String],
                                              approvalCount: document.data()["approvalCount"] as! Int,
                                              rejectionCount: document.data()["rejectionCount"] as! Int,
                                              approvalUsers: document.data()["approvalUsers"] as! [String],
                                              rejectionUsers: document.data()["rejectionUsers"] as! [String],
                                              rejectionReason: document.data()["rejectionReason"] as! [String])
                        pageContent.append(document.data()["id"] as! String)
                        funFacts.append(funFact)
                    }
                    completion(funFacts, pageContent, nil)
                }
        }
    }
    
    /// Updates user profile from Edit profile page
    func updateUserProfile(fullName: String, userName: String, city: String, country: String, photoURL: String, completion: @escaping (String?) -> ()) {
        db.collection("users")
            .document(Auth.auth().currentUser?.uid ?? "")
            .setData(["name": fullName,
                      "userName": userName,
                      "city": city,
                      "country": country,
                      "photoURL": photoURL],
                     merge: true) { (error) in
                        if let error = error {
                            print ("Error while updating user profile \(error.localizedDescription)")
                        } else {
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.displayName = fullName
                            changeRequest?.photoURL = URL(fileURLWithPath: photoURL)
                            changeRequest?.commitChanges(completion: { (error) in
                                if let error = error {
                                    completion(error.localizedDescription)
                                } else {
                                    completion(nil)
                                }
                            })
                        }
        }
    }
    
    /// Gets all the fun facts tagged by the hashtag
    func getFunFacts(for hashtag: String, completion: @escaping ([DocumentReference]?, String?) -> ()) {
        db.collection("hashtags").document(hashtag).collection("funFacts").getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                var refs = [DocumentReference]()
                for document in snapshot!.documents {
                    refs.append(document.data()["funFactID"] as! DocumentReference)
                }
                completion(refs, nil)
            }
        }
    }
    
    /// Retrieve all landmarks within the coordinates sorted by likes desc
    func getLandmarksInMapArea(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D, completion: @escaping (Landmark?, String?) -> ()) {
        let neCoord = CLLocation(latitude: neCoordinate.latitude, longitude: neCoordinate.longitude)
        let swCoord = CLLocation(latitude: swCoordinate.latitude, longitude: swCoordinate.longitude)
        if neCoord.distance(from: swCoord) > 200000 {
            completion(nil, FirestoreErrors.mapTooLarge)
            return
        }
        
        let neGeoPoint = GeoPoint(latitude: neCoordinate.latitude, longitude: neCoordinate.longitude)
        let swGeoPoint = GeoPoint(latitude: swCoordinate.latitude, longitude: swCoordinate.longitude)
        db.collection("landmarks")
            .whereField("coordinates", isGreaterThan: swGeoPoint)
            .whereField("coordinates", isLessThan: neGeoPoint)
            .order(by: "coordinates", descending: false)
            .order(by: "likes", descending: true)
            .limit(to: 30)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print ("error = \(error.localizedDescription)")
                    completion(nil, error.localizedDescription)
                } else {
                    print ("In else")
                    for document in (snapshot?.documents)! {
                        print (document.data()["name"] as! String)
                        for id in AppDataSingleton.appDataSharedInstance.listOfLandmarkIDs {
                            print ("Inside for")
                            if document.documentID == id {
                                print ("in for if")
                                completion(nil, FirestoreErrors.annotationExists)
                                return
                            }
                        }
                        let landmark = Landmark(id: document.data()["id"] as! String,
                                                name: document.data()["name"] as! String,
                                                address: document.data()["address"] as! String,
                                                city: document.data()["city"] as! String,
                                                state: document.data()["state"] as! String,
                                                zipcode: document.data()["zipcode"] as! String,
                                                country: document.data()["country"] as! String,
                                                type: document.data()["type"] as! String,
                                                coordinates: document.data()["coordinates"] as! GeoPoint,
                                                image: document.data()["image"] as! String,
                                                numOfFunFacts: document.data()["numOfFunFacts"] as! Int,
                                                likes: document.data()["likes"] as! Int,
                                                dislikes: document.data()["dislikes"] as! Int)
                        print (landmark.name)
                        completion(landmark, nil)
                    }
                }
        }
    }
    
    /// Get landmarks based on Landmark IDs
    func getLandmarks(landmarkIds: [String], completion: @escaping ([Landmark]?, String?) -> ()) {
        var landmarks = [Landmark]()
        for landmarkID in landmarkIds {
            db.collection("landmarks")
                .document(landmarkID)
                .getDocument { (snapshot, error) in
                if let error = error {
                    completion(nil, error.localizedDescription)
                } else {
                    let document = snapshot!
                    let landmark = Landmark(id: document.data()?["id"] as! String,
                                            name: document.data()?["name"] as! String,
                                            address: document.data()?["address"] as! String,
                                            city: document.data()?["city"] as! String,
                                            state: document.data()?["state"] as! String,
                                            zipcode: document.data()?["zipcode"] as! String,
                                            country: document.data()?["country"] as! String,
                                            type: document.data()?["type"] as! String,
                                            coordinates: document.data()?["coordinates"] as! GeoPoint,
                                            image: document.data()?["image"] as! String,
                                            numOfFunFacts: document.data()?["numOfFunFacts"] as! Int,
                                            likes: document.data()?["likes"] as! Int,
                                            dislikes: document.data()?["dislikes"] as! Int)
                    landmarks.append(landmark)
                    if landmarkIds.count == landmarks.count {
                        completion(landmarks, nil)
                    }
                }
            }
        }
    }
}
