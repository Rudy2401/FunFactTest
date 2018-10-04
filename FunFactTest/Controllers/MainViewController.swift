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
import FontAwesome_swift
import UserNotifications
import MapKitGoogleStyler
import FirebaseUI

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
    @IBOutlet weak var typeColor: UIView!
    
    var landmarkTitle = ""
    var landmarkID = ""
    var currentLocationCoordinate = CLLocationCoordinate2D()
    let jsonObject = FunFactJSONParser()
    var listOfLandmarks = ListOfLandmarks(listOfLandmarks: [])
    var listOfFunFacts = ListOfFunFacts(listOfFunFacts: [])
    var landmarkImage = UIImage()
    var annotations: [FunFactAnnotation]?
    var notificationCount = 0
    var profileToolButton: UIButton?
    var userProfile: User?
    
    // 1. create locationManager
    let locationManager = CLLocationManager()
    var notificationCenter: UNUserNotificationCenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeColor.layer.cornerRadius = 2.5

        annotationBottomView.alpha = 0.0
        self.hideKeyboardWhenTappedAround()
        setupToolbarAndNavigationbar()
        
        // 2. setup locationManager
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self
//        updateLikesDislikes()
//        updateUsersDisputes()
//        updateUserCounts()
        
        // 3. setup mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        currentLocationButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        currentLocationButton.setTitle(String.fontAwesomeIcon(name: .locationArrow), for: .normal)
        mapView.layoutMargins = UIEdgeInsets(top: 200, left: 0, bottom: 20, right: 0)
//        configureTileOverlay()
        
        // 4. setup Firestore data
        loadDataFromFirestore()
    }

    @IBAction func showCurrentLocation(_ sender: Any) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    func setupBottomView (annotationClicked: FunFactAnnotation, listOfLandmarks: [Landmark]) {
        typeColor.backgroundColor = Constants.getColorFor(type: annotationClicked.type)
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
        var landmark = Landmark(id: "", name: "", address: "", city: "", state: "", zipcode: "", country: "", type: "", latitude: "", longitude: "", image: "")
        
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
        addressLabel.text = landmark.address + ", " + landmark.city + ", " + landmark.state + ", " + landmark.country + ", " + landmark.zipcode
        let coordinate₁ = CLLocation(latitude: Double(landmark.latitude)!, longitude: Double(landmark.longitude)!)
        let distanceInMeters = CLLocation(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude).distance(from: coordinate₁)
        
        distanceLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        distanceLabel.textColor = UIColor.blue
        let distance = " " + String(format: "%.2f", distanceInMeters/1600) + " mi"
        let attrStringDist = NSAttributedString(string: distance, attributes: numOffAttr)
        let distanceComplete = NSMutableAttributedString()
        distanceComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .mapMarkerAlt)))
        distanceComplete.append(attrStringDist)
        distanceLabel.attributedText = distanceComplete
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
    
    func downloadUserProfile(completionHandler: @escaping (User) -> ())  {
        let db = Firestore.firestore()
        var user = User(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, email: "", name: "", phoneNumber: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [])
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (snapshot, error) in
            if let document = snapshot {
                user.dislikeCount = document.data()?["dislikeCount"] as! Int
                user.likeCount = document.data()?["likeCount"] as! Int
                user.disputeCount = document.data()?["disputeCount"] as! Int
                user.submittedCount = document.data()?["submittedCount"] as! Int
                user.email = document.data()?["email"] as! String
                user.name = document.data()?["name"] as! String
                user.phoneNumber = document.data()?["phoneNumber"] as! String
                user.photoURL = document.data()?["photoURL"] as! String
                user.provider = document.data()?["provider"] as! String
                user.uid = document.data()?["uid"] as! String
                
                self.downloadOtherUserData(collection: "funFactsLiked", completionHandler: { (ref) in
                    self.userProfile?.funFactsLiked = ref
                })
                self.downloadOtherUserData(collection: "funFactsDisliked", completionHandler: { (ref) in
                    self.userProfile?.funFactsDisliked = ref
                })
                self.downloadOtherUserData(collection: "funFactsSubmitted", completionHandler: { (ref) in
                    self.userProfile?.funFactsSubmitted = ref
                })
                self.downloadOtherUserData(collection: "funFactsDisputed", completionHandler: { (ref) in
                    self.userProfile?.funFactsDisputed = ref
                })
                
                completionHandler(user)
            }
            else {
                let err = error
                print("Error getting documents: \(String(describing: err))")
            }
        }
    }
    
    func downloadOtherUserData(collection: String, completionHandler: @escaping ([DocumentReference]) -> ()) {
        var refs = [DocumentReference]()
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").collection(collection).getDocuments() { (snap, error) in
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
    
    func setupFunFactDetailsBottomView(annotationClicked: FunFactAnnotation, listOfFunFacts: [FunFact]) {
        likeLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        likeLabel.textColor = UIColor.red
        
        var likePer = ""
        var like = 0
        var dislike = 0
        var count = 0
        for funFact in listOfFunFacts {
            if funFact.landmarkId == annotationClicked.landmarkID {
                like += funFact.likes
                dislike += funFact.dislikes
                count += 1
            }
        }
        if like + dislike == 0 {
            likePer = " 0%"
        }
        else {
            likePer = " " + String (like * 100 / (like + dislike)) + "%"
        }
        
        let attrStringLikePer = NSAttributedString(string: likePer, attributes: Constants.attribute12RegDG)
        let likePerComplete = NSMutableAttributedString()
        likePerComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .heart)))
        likePerComplete.append(attrStringLikePer)
        likeLabel.attributedText = likePerComplete
        
        noOfFunFactsLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        noOfFunFactsLabel.textColor = UIColor.brown
        
        let numOfFF = " " + String (count)
        
        let attrString = NSAttributedString(string: numOfFF, attributes: Constants.attribute12RegDG)
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
    
    @objc func mapViewTap(sender : UIGestureRecognizer) {
        setView(view: annotationBottomView,  alpha: 0.0)
    }
    
    func setView(view: UIView, alpha: CGFloat) {
        UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve, .curveEaseInOut], animations: {
            view.alpha = alpha
        }, completion: { finished in
            // Compeleted
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadUserProfile() { (user) in
            self.userProfile = user
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            profileToolButton?.addTarget(self, action: #selector(viewProfile), for: .touchUpInside)
        }
        else {

        }
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
        performSegue(withIdentifier: "funFactDetail", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromFirestore() {
        //4. Getting data from Firestore
        let firestore: FirestoreConnection = FirestoreConnection()
        let db = Firestore.firestore()
        downloadLandmarks(db)
        downloadFunFacts(db)
        
        
        let spinner = showLoader(view: self.view)
        firestore.downloadImagesIntoCache()
        firestore.createFunFactAnnotations() { annotations, error in
            if let error = error as Error? {
                print (error)
                return
            }
            self.mapView.addAnnotations(annotations)
            spinner.dismissLoader()
        }
    }
    func setupGeoFences(lat: Double, lon: Double, title: String, landmarkID: String) {
        // 1. check if system can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            // 2. region data
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let regionRadius = 300.0
            
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
        
        let destinationVC = segue.destination as? FunFactPageViewController
        var pageContent = Array<Any>()
        for i in 0..<listOfFunFacts.listOfFunFacts.count {
            if listOfFunFacts.listOfFunFacts[i].landmarkId == landmarkID {
                pageContent.append(listOfFunFacts.listOfFunFacts[i].id)
            }
        }
        var address = ""
        for i in listOfLandmarks.listOfLandmarks {
            if i.id == landmarkID {
                address = i.address
            }
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        destinationVC?.pageContent = pageContent as NSArray
        destinationVC?.headingContent = landmarkTitle
        destinationVC?.landmarkID = landmarkID
        destinationVC?.listOfFunFacts = listOfFunFacts
        destinationVC?.listOfLandmarks = listOfLandmarks
        destinationVC?.address = address
        destinationVC?.userProfile = userProfile!
        
        let destinationAddFactVC = segue.destination as? AddNewFactViewController
        destinationAddFactVC?.listOfLandmarks.listOfLandmarks = listOfLandmarks.listOfLandmarks
        destinationAddFactVC?.listOfFunFacts.listOfFunFacts = listOfFunFacts.listOfFunFacts
        
        let profileViewVC = segue.destination as? ProfileViewController
        profileViewVC?.userProfile = userProfile
    }
    
    func downloadFunFacts(_ db: Firestore) {
        db.collection("funFacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
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
                    self.listOfFunFacts.listOfFunFacts.append(funFact)
                }
            }
        }
    }
    
    func downloadLandmarks(_ db: Firestore) {
        db.collection("landmarks").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                for document in querySnapshot!.documents {
                    let landmark = Landmark(id: document.data()["id"] as! String,
                                            name: document.data()["name"] as! String,
                                            address: document.data()["address"] as! String,
                                            city:  document.data()["city"] as! String,
                                            state:  document.data()["state"] as! String,
                                            zipcode: document.data()["zipcode"] as! String ,
                                            country: document.data()["country"] as! String,
                                            type: document.data()["type"] as! String,
                                            latitude: document.data()["latitude"] as! String,
                                            longitude: document.data()["longitude"] as! String,
                                            image: document.data()["image"] as! String)
                    self.listOfLandmarks.listOfLandmarks.append(landmark)
                    self.setupGeoFences(lat: Double(document.data()["latitude"] as! String)!,
                                        lon: Double(document.data()["longitude"] as! String)!,
                                        title: document.data()["name"] as! String,
                                        landmarkID: document.data()["id"] as! String)
                    let source = (querySnapshot?.metadata.isFromCache)! ? "local cache" : "server"
                    print("Metadata: Data fetched from \(source)")
                }
            }
        }
    }
    
    func setupToolbarAndNavigationbar () {
        
        let addFactLabel1 = String.fontAwesomeIcon(name: .plus)
        let addFactLabelAttr1 = NSAttributedString(string: addFactLabel1, attributes: Constants.toolBarImageSolidAttribute)
        let addFactLabelAttrClicked1 = NSAttributedString(string: addFactLabel1, attributes: Constants.toolBarImageClickedAttribute)
        
        let addFactLabel2 = "\nAdd Fact"
        let addFactLabelAttr2 = NSAttributedString(string: addFactLabel2, attributes: Constants.toolBarLabelAttribute)
        let addFactLabelAttrClicked2 = NSAttributedString(string: addFactLabel2, attributes: Constants.toolBarLabelClickedAttribute)
        
        let completeAddFactLabel = NSMutableAttributedString()
        completeAddFactLabel.append(addFactLabelAttr1)
        completeAddFactLabel.append(addFactLabelAttr2)
        
        let completeAddFactLabelClicked = NSMutableAttributedString()
        completeAddFactLabelClicked.append(addFactLabelAttrClicked1)
        completeAddFactLabelClicked.append(addFactLabelAttrClicked2)
        
        let addFact = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 4, height: self.view.frame.size.height))
        addFact.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        addFact.setAttributedTitle(completeAddFactLabel, for: .normal)
        addFact.setAttributedTitle(completeAddFactLabelClicked, for: .selected)
        addFact.setAttributedTitle(completeAddFactLabelClicked, for: .highlighted)
        addFact.titleLabel?.textAlignment = .center
        addFact.addTarget(self, action: #selector(viewAddFact), for: .touchUpInside)
        
        let addFactBtn = UIBarButtonItem(customView: addFact)
        
        let profileLabel1 = String.fontAwesomeIcon(name: .user)
        let profileLabelAttr1 = NSAttributedString(string: profileLabel1, attributes: Constants.toolBarImageSolidAttribute)
        let profileLabelAttrClicked1 = NSAttributedString(string: profileLabel1, attributes: Constants.toolBarImageClickedAttribute)
        
        let profileLabel2 = "\nProfile"
        let profileLabelAttr2 = NSAttributedString(string: profileLabel2, attributes: Constants.toolBarLabelAttribute)
        let profileLabelAttrClicked2 = NSAttributedString(string: profileLabel2, attributes: Constants.toolBarLabelClickedAttribute)
        
        let completeProfileLabel = NSMutableAttributedString()
        completeProfileLabel.append(profileLabelAttr1)
        completeProfileLabel.append(profileLabelAttr2)
        
        let completeProfileLabelClicked = NSMutableAttributedString()
        completeProfileLabelClicked.append(profileLabelAttrClicked1)
        completeProfileLabelClicked.append(profileLabelAttrClicked2)
        
        let profile = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 4, height: self.view.frame.size.height))
        profile.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        profile.setAttributedTitle(completeProfileLabel, for: .normal)
        profile.setAttributedTitle(completeProfileLabelClicked, for: .selected)
        profile.setAttributedTitle(completeProfileLabelClicked, for: .highlighted)
        profile.titleLabel?.textAlignment = .center
        
        let profileBtn = UIBarButtonItem(customView: profile)
        self.profileToolButton = profile
        
        let settingsLabel1 = String.fontAwesomeIcon(name: .cog)
        let settingsAttr1 = NSAttributedString(string: settingsLabel1, attributes: Constants.toolBarImageSolidAttribute)
        
        let settingsLabel2 = "\nSettings"
        let settingsAttr2 = NSAttributedString(string: settingsLabel2, attributes: Constants.toolBarLabelAttribute)
        
        let completeSettingsLabel = NSMutableAttributedString()
        completeSettingsLabel.append(settingsAttr1)
        completeSettingsLabel.append(settingsAttr2)
        
        let settings = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 4, height: self.view.frame.size.height))
        settings.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        settings.setTitleColor(UIColor.gray, for: .normal)
        settings.setTitleColor(UIColor.darkGray, for: .highlighted)
        settings.setAttributedTitle(completeSettingsLabel, for: .normal)
        settings.titleLabel?.textAlignment = .center
        //        addFact.addTarget(self, action: #selector(tapppedToolBarBtn), for: .touchUpInside)
        let settingsBtn = UIBarButtonItem(customView: settings)
        
        let toolBarItems: [UIBarButtonItem]
        toolBarItems = [addFactBtn, Constants.flexibleSpace, profileBtn, Constants.flexibleSpace, settingsBtn]
        self.setToolbarItems(toolBarItems, animated: true)
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: customFont ]
        }
    }
    func showLoader(view: UIView) -> UIActivityIndicatorView {
        
        //Customize as per your need
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        spinner.backgroundColor = UIColor.clear
        spinner.layer.cornerRadius = 3.0
        spinner.clipsToBounds = true
        spinner.hidesWhenStopped = true
        spinner.style = UIActivityIndicatorView.Style.gray
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        return spinner
    }
}
extension MainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        if let annotation = view.annotation as? FunFactAnnotation {
            setupBottomView(annotationClicked: annotation, listOfLandmarks: self.listOfLandmarks.listOfLandmarks)
            setupFunFactDetailsBottomView(annotationClicked: annotation, listOfFunFacts: self.listOfFunFacts.listOfFunFacts)
        }
        else {
            
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
        switch (annotation as! FunFactAnnotation).type {
        case Constants.landmarkTypes[1]:
            color = .orange
            image = UIImage.fontAwesomeIcon(name: .home, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
        case Constants.landmarkTypes[2]:
            color = .blue
            image = UIImage.fontAwesomeIcon(name: .building, style: .solid, textColor: .white, size: CGSize(width: 20, height: 20))
        case Constants.landmarkTypes[3]:
            color = .black
            image = UIImage.fontAwesomeIcon(name: .footballBall, style: .solid, textColor: .white, size: CGSize(width: 20, height: 20))
        case Constants.landmarkTypes[4]:
            color = .green
            image = UIImage.fontAwesomeIcon(name: .book, style: .solid, textColor: .white, size: CGSize(width: 20, height: 20))
        case Constants.landmarkTypes[5]:
            color = .cyan
            image = UIImage.fontAwesomeIcon(name: .tree, style: .solid, textColor: .white, size: CGSize(width: 20, height: 20))
        case Constants.landmarkTypes[6]:
            color = .gray
            image = UIImage.fontAwesomeIcon(name: .utensils, style: .solid, textColor: .white, size: CGSize(width: 20, height: 20))
        case Constants.landmarkTypes[7]:
            color = .purple
            image = UIImage.fontAwesomeIcon(name: .university, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))

        default:
            color = .red
        }
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
        guard let overlayFileURLString = Bundle.main.path(forResource: "overlay-sharp", ofType: "json") else {
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
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    // 1. user enter region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Warning", message: "enter \(region.identifier)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
//        showNotification(forRegion: region)
    }
    
    // 2. user exit region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Warning", message: "exit \(region.identifier)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = manager.location else{
            return
        }
        let currentLocationCoordinate = location.coordinate
        self.currentLocationCoordinate = currentLocationCoordinate
    }
    
//    func showNotification(forRegion region: CLRegion!) {
//
//        // customize your notification content
//        let content = UNMutableNotificationContent()
//        content.title = "Near " + region.identifier + "?"
//        content.subtitle = "Did you know?"
//
//        var tempLandmarkID = ""
//        for landmark in listOfLandmarks.listOfLandmarks {
//            if region.identifier == landmark.name {
//                tempLandmarkID = landmark.id
//                break
//            }
//        }
//        for funFact in listOfFunFacts.listOfFunFacts {
//            if funFact.landmarkId == tempLandmarkID {
//                content.body = (self.listOfFunFacts.listOfFunFacts.first?.description)!
//
//                let imageName = "\(funFact.image).jpeg"
//                let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
//                if imageFromCache != nil {
//                    let imageData = UIImageJPEGRepresentation(imageFromCache!, 1.0)
//                    guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "\(funFact.image).jpeg", data: imageData! as NSData, options: nil) else { return  }
//                    content.attachments = [attachment]
//                    break
//                } else {
//                    let s = funFact.id
//                    let imageName = "\(s).jpeg"
//
//                    let storage = Storage.storage()
//                    let gsReference = storage.reference(forURL: "gs://funfacts-5b1a9.appspot.com/images/\(imageName)")
//
//                    gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                        if let error = error {
//                            print("error = \(error)")
//                        } else {
//                            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "\(funFact.image).jpeg", data: data! as NSData, options: nil) else { return  }
//                            content.attachments = [attachment]
//                        }
//                    }
//                    break
//                }
//            }
//        }
//        content.sound = UNNotificationSound.default()
//        notificationCount += 1
//
//        // when the notification will be triggered
//        let timeInSeconds: TimeInterval = (6) // 60s * 15 = 15min
//        // the actual trigger object
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
//                                                        repeats: false)
//
//        // notification unique identifier, for this example, same as the region to avoid duplicate notifications
//        let identifier = region.identifier
//
//        // the notification request object
//        let request = UNNotificationRequest(identifier: identifier,
//                                            content: content,
//                                            trigger: trigger)
//
//        // trying to add the notification request to notification center
//        notificationCenter?.add(request, withCompletionHandler: { (error) in
//            if error != nil {
//                print("Error adding notification with identifier: \(identifier)")
//            }
//        })
//    }
}
//extension UNNotificationAttachment {
    
    /// Save the image to disk
//    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
//        let fileManager = FileManager.default
//        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
//        let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
//
//        do {
//            try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
//            let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
//            try data.write(to: fileURL!, options: [])
//            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL!, options: options)
//            return imageAttachment
//        } catch let error {
//            print("error \(error)")
//        }
//        return nil
//    }
//
//}

//extension MainViewController: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        // when app is open and in foregroud
//        completionHandler(.alert)
//    }
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        // get the notification identifier to respond accordingly
//        let identifier = response.notification.request.identifier
//        print ("identifier = \(identifier)")
//        // do what you need to do
//
//        // ...
//    }
//}
