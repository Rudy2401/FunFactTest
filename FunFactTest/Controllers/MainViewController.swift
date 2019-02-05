//
//  ViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/20/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseStorage
import UserNotifications
import MapKitGoogleStyler
import FirebaseUI
import InstantSearch


class MainViewController: UIViewController {
    
    @IBOutlet var annotationBottomView: AnnotationBottomView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var currentLocationButton: UIButton!
    @IBOutlet var landmarkImageView: UIImageView!
    @IBOutlet var titleAnnotationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var noOfFunFactsLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var typeColor: UIView!
    @IBOutlet var addFactButton: UIButton!
    
    
    var landmarkTitle = ""
    var landmarkID = ""
    var currentLocationCoordinate = CLLocationCoordinate2D()
    let jsonObject = FunFactJSONParser()
    var landmarkImage = UIImage()
    var annotations: [FunFactAnnotation]?
    var notificationCount = 0
    var landmarkType = ""
    var userProfile = User(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, email: "", name: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [])
    var boundingBox: GeoRect?
    
    // 1. create locationManager
    let locationManager = CLLocationManager()
    var notificationCenter: UNUserNotificationCenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeColor.layer.cornerRadius = 2.5
        
        annotationBottomView.alpha = 0.0
        setupNavigationbar()
        
        for landmark in AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks {
            self.setupGeoFences(lat: landmark.coordinates.latitude,
                                lon: landmark.coordinates.longitude,
                                title: landmark.name,
                                landmarkID: landmark.id)
        }
        
        downloadUserProfile(Auth.auth().currentUser?.uid ?? "") { (user) in
            AppDataSingleton.appDataSharedInstance.userProfile = user
        }
        downloadAllUserData()
        // 2. setup locationManager
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // register as it's delegate
        notificationCenter?.delegate = self
        // get the singleton object
        notificationCenter = UNUserNotificationCenter.current()
        //        updateLikesDislikes()
        //        updateUsersDisputes()
        //        updateUserCounts()
        //        renameAndDeleteLandmarks()
        //        updateUsers()
        
        // 3. setup mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        currentLocationButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .light)
        currentLocationButton.setTitle(String.fontAwesomeIcon(name: .location), for: .normal)
        
        let addFactLabel = String.fontAwesomeIcon(name: .plus)
        let addFactLabelAttr = NSAttributedString(string: addFactLabel, attributes: Attributes.addFactButtonAttribute)
        let addFactLabelAttrClicked = NSAttributedString(string: addFactLabel, attributes: Attributes.toolBarImageClickedAttribute)
        
        addFactButton.backgroundColor = Colors.seagreenColor
        addFactButton.clipsToBounds = true
        addFactButton.layer.cornerRadius = 25
        addFactButton.layer.shadowPath = UIBezierPath(roundedRect: addFactButton.bounds, cornerRadius: 25).cgPath
        addFactButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        addFactButton.layer.shadowOffset = CGSize(width: 0, height: 9)
        addFactButton.layer.shadowOpacity = 1.0
        addFactButton.layer.shadowRadius = 10.0
        addFactButton.layer.masksToBounds = false
        addFactButton.setAttributedTitle(addFactLabelAttr, for: .normal)
        addFactButton.setAttributedTitle(addFactLabelAttrClicked, for: .selected)
        addFactButton.setAttributedTitle(addFactLabelAttrClicked, for: .highlighted)
        addFactButton.titleLabel?.textAlignment = .center
        
        mapView.layoutMargins = UIEdgeInsets(top: 200, left: 0, bottom: 20, right: 0)
//        configureTileOverlay()
        
        // 4. setup Firestore data
        loadDataFromFirestoreAndAddAnnotations()
    }
    
    @IBAction func viewAddFact(_ sender: Any) {
        performSegue(withIdentifier: "addFactDetail", sender: self)
    }
    
    @IBAction func showCurrentLocation(_ sender: Any) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    func setupBottomView (annotationClicked: FunFactAnnotation, listOfLandmarks: Set<Landmark>) {
        typeColor.backgroundColor = Constants.getMarkerDetails(type: annotationClicked.type).color
        annotationBottomView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        annotationBottomView.layer.shadowOffset = CGSize(width: 0, height: 3)
        annotationBottomView.layer.shadowOpacity = 1.0
        annotationBottomView.layer.shadowRadius = 10.0
        annotationBottomView.layer.masksToBounds = false
        
        annotationBottomView.backgroundColor = UIColor.white
        annotationBottomView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        annotationBottomView.layer.borderWidth = CGFloat.init(0.2)
        annotationBottomView.layer.borderColor = UIColor.lightGray.cgColor
        annotationBottomView.layer.cornerRadius = 5
        let numOffAttr = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                           NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 12.0)!]
        var landmark = Landmark(id: "", name: "", address: "", city: "", state: "", zipcode: "", country: "", type: "", coordinates: GeoPoint(latitude: 0, longitude: 0), image: "", numOfFunFacts: 0, likes: 0, dislikes: 0 )
        
        for lm in listOfLandmarks {
            if lm.id == annotationClicked.landmarkID {
                landmark = lm
            }
        }
        
        landmarkTitle = (annotationClicked.title)!
        landmarkID = annotationClicked.landmarkID
        
        setupImage(landmark)
        
        titleAnnotationLabel.text = landmark.name
        typeLabel.text = landmark.type
        landmarkType = landmark.type
        addressLabel.text = landmark.address + ", " + landmark.city + ", " + landmark.state + ", " + landmark.country + ", " + landmark.zipcode
        let coordinate₁ = CLLocation(latitude: landmark.coordinates.latitude, longitude: landmark.coordinates.longitude) 
        let distanceInMeters = CLLocation(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude).distance(from: coordinate₁)
        
        distanceLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        distanceLabel.textColor = UIColor.blue
        let distance = " " + String(format: "%.2f", distanceInMeters/1600) + " mi"
        let attrStringDist = NSAttributedString(string: distance, attributes: numOffAttr)
        let distanceComplete = NSMutableAttributedString()
        distanceComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .mapMarkerAlt)))
        distanceComplete.append(attrStringDist)
        distanceLabel.attributedText = distanceComplete
        
        likeLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        likeLabel.textColor = UIColor.red
        
        var likePer = ""
        var like = 0
        var dislike = 0
        
        like += landmark.likes
        dislike += landmark.dislikes

        if like + dislike == 0 {
            likePer = " 0%"
        }
        else {
            likePer = " " + String (like * 100 / (like + dislike)) + "%"
        }
        
        let attrStringLikePer = NSAttributedString(string: likePer, attributes: Attributes.attribute12RegDG)
        let likePerComplete = NSMutableAttributedString()
        likePerComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .heart)))
        likePerComplete.append(attrStringLikePer)
        likeLabel.attributedText = likePerComplete
        
        noOfFunFactsLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        noOfFunFactsLabel.textColor = UIColor.brown
        
        let numOfFF = " " + String (landmark.numOfFunFacts)
        
        let attrString = NSAttributedString(string: numOfFF, attributes: Attributes.attribute12RegDG)
        let numOfFFComplete = NSMutableAttributedString()
        numOfFFComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .file)))
        numOfFFComplete.append(attrString)
        noOfFunFactsLabel.attributedText = numOfFFComplete
        
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewBottomAnnotation))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        annotationBottomView.addGestureRecognizer(mytapGestureRecognizer)
        annotationBottomView.isUserInteractionEnabled = true
        
        setView(view: annotationBottomView,  alpha: 1.0)
        
        let mapViewGesture = UITapGestureRecognizer(target: self, action: #selector(mapViewTap))
        mapViewGesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(mapViewGesture)
        mapView.isUserInteractionEnabled = true
    }
    
    func setupImage(_ landmark: Landmark) {
        let imageId = landmark.image
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            self.landmarkImageView.image = imageFromCache
            self.landmarkImageView!.layer.cornerRadius = 5
        } else {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            self.landmarkImageView.sd_setImage(with: gsReference, placeholderImage: UIImage())
            self.landmarkImageView.layer.cornerRadius = 5
        }
    }
    
    func setupImage(_ funFact: FunFact) {
        print(funFact.image)
        let imageId = funFact.image
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            //            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // Put your code which should be executed with a delay here
            self.landmarkImageView.image = imageFromCache
            //            })
            self.landmarkImageView!.layer.cornerRadius = 5
        } else {
            //            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            self.landmarkImageView.sd_setImage(with: gsReference, placeholderImage: UIImage())
            self.landmarkImageView.layer.cornerRadius = 5
            //            })
        }
    }

    
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
    
    @objc func mapViewTap(sender : UIGestureRecognizer) {
        setView(view: annotationBottomView,  alpha: 0.0)
    }
    
    func setView(view: UIView, alpha: CGFloat) {
        if alpha == 1.0 {
            view.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
            UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve, .curveEaseInOut], animations: {
                view.alpha = alpha
                view.transform = .identity
            }, completion: nil)
            UIView.animate(withDuration: 0.5, animations: {
                self.addFactButton.transform = CGAffineTransform(translationX: 0, y: -110)
            }, completion: nil)
        } else {
            view.transform = CGAffineTransform(translationX: 0, y: 0)
            UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve, .curveEaseInOut], animations: {
                view.alpha = alpha
                view.transform = .identity
            }, completion: nil)
            UIView.animate(withDuration: 0.5, animations: {
                self.addFactButton.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController!.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10.0)
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Warning", message: "Location services were previously denied. Please enable location services for this app in Settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
    }
    @objc func viewAddFact(recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "addFactDetail", sender: self)
    }
    
    @objc func viewProfile(recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    @objc func viewBottomAnnotation(recognizer: UITapGestureRecognizer) {
        let db = Firestore.firestore()
        downloadFunFacts(for: landmarkID, db: db)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromFirestoreAndAddAnnotations() {
        //4. Getting data from Firestore
        let firestore: FirestoreConnection = FirestoreConnection()
        
        downloadLandmarks(caller: "viewDidLoad")
        firestore.downloadImagesIntoCache()
    }
    func setupGeoFences(lat: Double, lon: Double, title: String, landmarkID: String) {
        // 1. check if system can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            // 2. region data
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let regionRadius = 100.0
            
            // 3. setup region
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat,
                                                                         longitude: lon),
                                          radius: regionRadius,
                                          identifier: title)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
            
            // 5. setup circle
            let circle = MKCircle(center: coordinate, radius: regionRadius)
            mapView.addOverlay(circle)
        }
        else {
            print("System can't track regions")
        }
    }
    //     MARK: - Navigation
    //
    //     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    func addLotOfStuff() {
        let la = FunFact(landmarkId: "land", id: "qwe", description: "qwerty", likes: 0, dislikes: 0, verificationFlag: "Y", image: "QWE", imageCaption: "zc", disputeFlag: "N", submittedBy: "asdfc", dateSubmitted: "asd", source: "asd", tags: ["qwerty"])
        
        for _ in 0...1000000 {
            AppDataSingleton.appDataSharedInstance.listOfFunFacts.listOfFunFacts.insert(la)
        }
    }
    
    
    func downloadUserProfile(_ uid: String, completionHandler: @escaping (User) -> ())  {
        if Auth.auth().currentUser == nil {
            return
        }
        let db = Firestore.firestore()
        var user = User(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, email: "", name: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [])
        db.collection("users").document(uid).getDocument { (snapshot, error) in
            if let document = snapshot {
                user.dislikeCount = document.data()?["dislikeCount"] as! Int
                user.likeCount = document.data()?["likeCount"] as! Int
                user.disputeCount = document.data()?["disputeCount"] as! Int
                user.submittedCount = document.data()?["submittedCount"] as! Int
                user.email = document.data()?["email"] as! String
                user.name = document.data()?["name"] as! String
                user.photoURL = document.data()?["photoURL"] as! String
                user.provider = document.data()?["provider"] as! String
                user.uid = document.data()?["uid"] as! String
                
                self.downloadOtherUserData(Auth.auth().currentUser?.uid ?? "", collection: "funFactsLiked", completionHandler: { (ref) in
                    AppDataSingleton.appDataSharedInstance.userProfile.funFactsLiked = ref
                })
                self.downloadOtherUserData(Auth.auth().currentUser?.uid ?? "", collection: "funFactsDisliked", completionHandler: { (ref) in
                    AppDataSingleton.appDataSharedInstance.userProfile.funFactsDisliked = ref
                })
                self.downloadOtherUserData(Auth.auth().currentUser?.uid ?? "", collection: "funFactsSubmitted", completionHandler: { (ref) in
                    AppDataSingleton.appDataSharedInstance.userProfile.funFactsSubmitted = ref
                })
                self.downloadOtherUserData(Auth.auth().currentUser?.uid ?? "", collection: "funFactsDisputed", completionHandler: { (ref) in
                    AppDataSingleton.appDataSharedInstance.userProfile.funFactsDisputed = ref
                })
                
                completionHandler(user)
            }
            else {
                let err = error
                print("Error getting documents: \(String(describing: err))")
            }
        }
    }
    func downloadOtherUserData(_ uid: String, collection: String, completionHandler: @escaping ([DocumentReference]) -> ()) {
        var refs = [DocumentReference]()
        let db = Firestore.firestore()
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
    
    func downloadAllUserData() {
        let db = Firestore.firestore()
        var user = User(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, email: "", name: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [])
        db.collection("users").getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for doc in snapshot!.documents {
                    let uid = doc.data()["uid"] as! String
                    user.uid = uid
                    user.dislikeCount = doc.data()["dislikeCount"] as! Int
                    user.disputeCount = doc.data()["disputeCount"] as! Int
                    user.likeCount = doc.data()["likeCount"] as! Int
                    user.submittedCount = doc.data()["submittedCount"] as! Int
                    user.email = doc.data()["email"] as! String
                    user.name = doc.data()["name"] as! String
                    user.photoURL = doc.data()["photoURL"] as! String
                    user.provider = doc.data()["provider"] as! String
                    AppDataSingleton.appDataSharedInstance.usersDict[uid] = user
                    
                    self.downloadOtherUserData(uid, collection: "funFactsLiked", completionHandler: { (ref) in
                        AppDataSingleton.appDataSharedInstance.usersDict[uid]?.funFactsLiked = ref
                    })
                    self.downloadOtherUserData(uid, collection: "funFactsDisliked", completionHandler: { (ref) in
                        AppDataSingleton.appDataSharedInstance.usersDict[uid]?.funFactsDisliked = ref
                    })
                    self.downloadOtherUserData(uid, collection: "funFactsSubmitted", completionHandler: { (ref) in
                        AppDataSingleton.appDataSharedInstance.usersDict[uid]?.funFactsSubmitted = ref
                    })
                    self.downloadOtherUserData(uid, collection: "funFactsDisputed", completionHandler: { (ref) in
                        AppDataSingleton.appDataSharedInstance.usersDict[uid]?.funFactsDisputed = ref
                    })
                    
                }
            }
        }
    }
    
    func setupNavigationbar () {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: customFont ]
        }
    }
    func showLoader(view: UIView) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        spinner.backgroundColor = UIColor.clear
        spinner.color = UIColor.black
        spinner.layer.cornerRadius = 3.0
        spinner.clipsToBounds = true
        spinner.hidesWhenStopped = true
        spinner.style = UIActivityIndicatorView.Style.gray
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        //        UIApplication.shared.beginIgnoringInteractionEvents()
        
        return spinner
    }
}
extension MainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        if let annotation = view.annotation as? FunFactAnnotation {
            setupBottomView(annotationClicked: annotation, listOfLandmarks: AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        var annotationView = MKMarkerAnnotationView()
        guard annotation is FunFactAnnotation else { return nil }
        
        let identifier = "annotation"
        var image = UIImage()
        var color = UIColor.red
        image = Constants.getMarkerDetails(type: (annotation as! FunFactAnnotation).type).image
        color = Constants.getMarkerDetails(type: (annotation as! FunFactAnnotation).type).color
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        self.typeColor.backgroundColor = color
        annotationView.markerTintColor = color
        annotationView.glyphImage = image
        annotationView.glyphTintColor = .white
        annotationView.clusteringIdentifier = identifier
        return annotationView
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // This is the final step. This code can be copied and pasted into your project
        // without thinking on it so much. It simply instantiates a MKTileOverlayRenderer
        // for displaying the tile overlay.
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    private func configureTileOverlay() {
        // We first need to have the path of the overlay configuration JSON
        guard let overlayFileURLString = Bundle.main.path(forResource: "overlay-light", ofType: "json") else {
            return
        }
        let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
        
        // After that, you can create the tile overlay using MapKitGoogleStyler
        guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
            return
        }
        
        // And finally add it to your MKMapView
        mapView.addOverlay(tileOverlay)
    }
    
}

