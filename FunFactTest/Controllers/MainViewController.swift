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
    
    var landmarkTitle = ""
    var landmarkID = ""
    var currentLocationCoordinate = CLLocationCoordinate2D()
    let jsonObject = FunFactJSONParser()
    var listOfLandmarks = ListOfLandmarks(listOfLandmarks: [])
    var listOfFunFacts = ListOfFunFacts(listOfFunFacts: [])
    var landmarkImage = UIImage()
    var annotations: [FunFactAnnotation]?
    var notificationCount = 0
    
    // 1. create locationManager
    let locationManager = CLLocationManager()
    var notificationCenter: UNUserNotificationCenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        annotationBottomView.isHidden = true
        self.hideKeyboardWhenTappedAround()
        setupToolbarAndNavigationbar()
        
        // 2. setup locationManager
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self
        
        // get the singleton object
        self.notificationCenter = UNUserNotificationCenter.current()
        
        // register as it's delegate
        notificationCenter?.delegate = self as? UNUserNotificationCenterDelegate
        
        // define what do you need permission to use
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        // request permission
        notificationCenter?.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }
        
        // 3. setup mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        currentLocationButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        currentLocationButton.setTitle(String.fontAwesomeIcon(name: .locationArrow), for: .normal)
        
        // 4. setup Firestore data
        loadDataFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @IBAction func showCurrentLocation(_ sender: Any) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    func setupBottomView (annotationClicked: FunFactAnnotation, listOfLandmarks: [Landmark]) {
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
        let numOffAttr = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                           NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 12.0)!]
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
            
            var image = UIImage()
            
            let storage = Storage.storage()
            let gsReference = storage.reference(forURL: "gs://funfacts-5b1a9.appspot.com/images/\(imageName)")
            
            gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error = \(error)")
                } else {
                    image = UIImage(data: data!)!
                    self.landmarkImageView.image = image
                    self.landmarkImageView!.layer.cornerRadius = 5
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
                like += Int(funFact.likes)!
                dislike += Int(funFact.dislikes)!
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
        setView(view: annotationBottomView,  hidden: false)
        
        let mapViewGesture = UITapGestureRecognizer(target: self, action: #selector(mapViewTap))
        mapViewGesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(mapViewGesture)
        mapView.isUserInteractionEnabled = true
        
    }
    
    @objc func mapViewTap(sender : UIGestureRecognizer) {
        setView(view: annotationBottomView,  hidden: true)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
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
        performSegue(withIdentifier: "addFactDetail", sender: nil)
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
            mapView.add(circle)
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
                pageContent.append(listOfFunFacts.listOfFunFacts[i].description)
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
        
        let destinationAddFactVC = segue.destination as? AddNewFactViewController
        destinationAddFactVC?.listOfLandmarks.listOfLandmarks = listOfLandmarks.listOfLandmarks
        destinationAddFactVC?.listOfFunFacts.listOfFunFacts = listOfFunFacts.listOfFunFacts
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
                                          likes: document.data()["likes"] as! String,
                                          dislikes: document.data()["dislikes"] as! String,
                                          verificationFlag: document.data()["verificationFlag"] as? String ?? "",
                                          image: document.data()["imageName"] as! String,
                                          imageCaption: document.data()["imageCaption"] as? String ?? "",
                                          disputeFlag: document.data()["disputeFlag"] as! String,
                                          submittedBy: document.data()["submittedBy"] as! String,
                                          dateSubmitted: document.data()["dateSubmitted"] as! String,
                                          source: document.data()["source"] as! String)
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
        
        let profileLabel2 = "\nProfile"
        let profileLabelAttr2 = NSAttributedString(string: profileLabel2, attributes: Constants.toolBarLabelAttribute)
        
        let completeProfileLabel = NSMutableAttributedString()
        completeProfileLabel.append(profileLabelAttr1)
        completeProfileLabel.append(profileLabelAttr2)
        
        let profile = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 4, height: self.view.frame.size.height))
        profile.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        profile.setTitleColor(UIColor.gray, for: .normal)
        profile.setTitleColor(UIColor.darkGray, for: .highlighted)
        profile.setAttributedTitle(completeProfileLabel, for: .normal)
        profile.titleLabel?.textAlignment = .center
        //        addFact.addTarget(self, action: #selector(tapppedToolBarBtn), for: .touchUpInside)
        let profileBtn = UIBarButtonItem(customView: profile)
        
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
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: customFont ]
        }
    }
    func showLoader(view: UIView) -> UIActivityIndicatorView {
        
        //Customize as per your need
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        spinner.backgroundColor = UIColor.clear
        spinner.layer.cornerRadius = 3.0
        spinner.clipsToBounds = true
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
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
        let annotation = view.annotation as! FunFactAnnotation
        if let view = view as? MKPinAnnotationView {
            view.pinTintColor = UIColor.gray
        }
        setupBottomView(annotationClicked: annotation, listOfLandmarks: self.listOfLandmarks.listOfLandmarks)
        setupFunFactDetailsBottomView(annotationClicked: annotation, listOfFunFacts: self.listOfFunFacts.listOfFunFacts)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView?.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
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
        showNotification(forRegion: region)
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
    
    func showNotification(forRegion region: CLRegion!) {
        
        // customize your notification content
        let content = UNMutableNotificationContent()
        content.title = "Near " + region.identifier + "?"
        content.subtitle = "Did you know?"
        
        var tempLandmarkID = ""
        for landmark in listOfLandmarks.listOfLandmarks {
            if region.identifier == landmark.name {
                tempLandmarkID = landmark.id
                break
            }
        }
        for funFact in listOfFunFacts.listOfFunFacts {
            if funFact.landmarkId == tempLandmarkID {
                content.body = (self.listOfFunFacts.listOfFunFacts.first?.description)!
                let imageData = UIImageJPEGRepresentation(CacheManager.shared.getFromCache(key: "\(funFact.image).jpeg") as! UIImage, 1.0)
                guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "\(funFact.image).jpeg", data: imageData! as NSData, options: nil) else { return  }

                content.attachments = [attachment]
                break
            }
        }
        content.sound = UNNotificationSound.default()
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
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is open and in foregroud
        completionHandler(.alert)
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
    }}
