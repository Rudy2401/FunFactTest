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
import FontAwesome_swift
import FirebaseStorage


class ViewController: UIViewController, CLLocationManagerDelegate {
    
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
    
    struct ListOfLandmarks  {
        var listOfLandmarks: [Landmark]
    }
    struct ListOfFunFacts  {
        var listOfFunFacts: [FunFact]
    }
    struct Landmark {
        let id: String
        let name: String
        let address: String
        let city: String
        let state: String
        let zipcode: String
        let country: String
        let type: String
        let latitude: String
        let longitude: String
        let image: String
    }
    struct FunFact  {
        let landmarkId: String
        let id: String
        let description: String
        let likes: String
        let dislikes: String
        let verificationFlag: String
        let image: String
        let disputeFlag: String
        let submittedBy: String
        let dateSubmitted: String
        let source: String
    }
    
    var landmarkTitle = ""
    var landmarkID = ""
    var currentLocationCoordinate = CLLocationCoordinate2D()
    let jsonObject = FunFactJSONParser()
    var listOfLandmarks = ListOfLandmarks(listOfLandmarks: [])
    var listOfFunFacts = ListOfFunFacts(listOfFunFacts: [])
    var landmarkImage = UIImage()
    
    
    // 1. create locationManager
    let locationManager = CLLocationManager()
    let util = Utils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        annotationBottomView.isHidden = true
        self.hideKeyboardWhenTappedAround() 
        setupToolbarAndNavigationbar()

        // 2. setup locationManager
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // 3. setup mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        currentLocationButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        currentLocationButton.setTitle(String.fontAwesomeIcon(name: .locationArrow), for: .normal)
        
        // 4. setup test data
        setupData()
    }
    
    @IBAction func showCurrentLocation(_ sender: Any) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    func setupBottomView (annotationClicked: FunFactAnnotation) {
        
        annotationBottomView.backgroundColor = UIColor.white
        annotationBottomView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        annotationBottomView.layer.borderWidth = CGFloat.init(0.2)
        annotationBottomView.layer.borderColor = UIColor.lightGray.cgColor
        annotationBottomView.layer.cornerRadius = 5
        
        let numOffAttr = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                             NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 12.0)!]
        var landmark = Landmark(id: "", name: "", address: "", city: "", state: "", zipcode: "", country: "", type: "", latitude: "", longitude: "", image: "")

        for lm in listOfLandmarks.listOfLandmarks {
            if lm.id == annotationClicked.landmarkID {
                landmark = lm
            }
        }
        
        landmarkTitle = (annotationClicked.title)!
        landmarkID = annotationClicked.landmarkID
        
        var image = UIImage()
        let s = landmark.image
        let imageName = "\(s).jpeg"
        
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
        
        likeLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        likeLabel.textColor = UIColor.red
        
        var likePer = ""
        var like = 0
        var dislike = 0
        var count = 0
        for funFact in listOfFunFacts.listOfFunFacts {
            if funFact.landmarkId == annotationClicked.landmarkID {
                like += Int(funFact.likes)!
                dislike += Int(funFact.dislikes)!
                count += 1
            }
        }
        if like + dislike == 0 {
            likePer = "0%"
        }
        else {
            likePer = " " + String (like * 100 / (like + dislike)) + "%"
        }
        
        let attrStringLikePer = NSAttributedString(string: likePer, attributes: numOffAttr)
        let likePerComplete = NSMutableAttributedString()
        likePerComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .heart)))
        likePerComplete.append(attrStringLikePer)
        likeLabel.attributedText = likePerComplete
        
        noOfFunFactsLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        noOfFunFactsLabel.textColor = UIColor.brown

        let numOfFF = " " + String (count)
        
        let attrString = NSAttributedString(string: numOfFF, attributes: numOffAttr)
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
    
    // 1. user enter region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Warning", message: "enter \(region.identifier)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 2. user exit region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Warning", message: "exit \(region.identifier)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupData() {
        // 1. check if system can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            // 2. region data

            let lat: Double = 40.7576393
            let lon: Double = -73.99792409999998
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

            
            let title = "Henry Hall"
            //let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735)
            let regionRadius = 300.0
            
            // 3. setup region
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat,
                                                                         longitude: lon), radius: regionRadius, identifier: title)
            locationManager.startMonitoring(for: region)
            
            //4. Adding map annotations
            let settings = FirestoreSettings()
            Firestore.firestore().settings = settings
            let db = Firestore.firestore()
//            addDataToFirestoreForLandmark(db: db, documentID: "L0000000001")
            createFunFactAnnotations(db: db)
            downloadFunFacts(db: db)

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
        //         Get the new view controller using segue.destinationViewController.
        //         Pass the selected object to the new view controller.
        
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
        destinationVC?.address = address
        
        let destinationAddFactVC = segue.destination as? AddFactViewController
        destinationAddFactVC?.listOfLandmarks.listOfLandmarks = listOfLandmarks.listOfLandmarks
        destinationAddFactVC?.listOfFunFacts.listOfFunFacts = listOfFunFacts.listOfFunFacts
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = manager.location else{
            return
        }
        let currentLocationCoordinate = location.coordinate
        self.currentLocationCoordinate = currentLocationCoordinate
    }
    
    func setupToolbarAndNavigationbar () {
        
        let toolBarAttrImageSolid = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                 NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 25, style: .solid)]
        
        let toolBarAttrLabel = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                 NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 10.0)!]
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let addFactLabel1 = String.fontAwesomeIcon(name: .plus)
        let addFactLabelAttr1 = NSAttributedString(string: addFactLabel1, attributes: toolBarAttrImageSolid)
        
        let addFactLabel2 = "\nAdd Fact"
        let addFactLabelAttr2 = NSAttributedString(string: addFactLabel2, attributes: toolBarAttrLabel)
        
        let completeAddFactLabel = NSMutableAttributedString()
        completeAddFactLabel.append(addFactLabelAttr1)
        completeAddFactLabel.append(addFactLabelAttr2)
        
        let addFact = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 4, height: self.view.frame.size.height))
        addFact.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        addFact.setTitleColor(UIColor.gray, for: .normal)
        addFact.setTitleColor(UIColor.darkGray, for: .highlighted)
        addFact.setAttributedTitle(completeAddFactLabel, for: .normal)
        addFact.titleLabel?.textAlignment = .center
        addFact.addTarget(self, action: #selector(viewAddFact), for: .touchUpInside)
        
        let addFactBtn = UIBarButtonItem(customView: addFact)
        
        let profileLabel1 = String.fontAwesomeIcon(name: .user)
        let profileLabelAttr1 = NSAttributedString(string: profileLabel1, attributes: toolBarAttrImageSolid)
        
        let profileLabel2 = "\nProfile"
        let profileLabelAttr2 = NSAttributedString(string: profileLabel2, attributes: toolBarAttrLabel)
        
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
        let settingsAttr1 = NSAttributedString(string: settingsLabel1, attributes: toolBarAttrImageSolid)
        
        let settingsLabel2 = "\nSettings"
        let settingsAttr2 = NSAttributedString(string: settingsLabel2, attributes: toolBarAttrLabel)
        
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
        toolBarItems = [addFactBtn, flexibleSpace, profileBtn, flexibleSpace, settingsBtn]
        self.setToolbarItems(toolBarItems, animated: true)
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: customFont ]
        }
    }
    
    func createFunFactAnnotations(db: Firestore) {
        db.collection("landmarks").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    var annotation: FunFactAnnotation

                    let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(document.data()["latitude"] as! String)!, longitude: CLLocationDegrees(document.data()["longitude"] as! String)!)
                    
                    annotation = FunFactAnnotation(landmarkID: document.data()["id"] as! String,
                                                   title: document.data()["name"] as! String,
                                                   address: "\(String(describing: document.data()["address"])), \(String(describing: document.data()["city"])), \(String(describing: document.data()["state"])), \(String(describing: document.data()["country"]))",
                                                   type: document.data()["type"] as! String,
                                                   coordinate: coordinates)
                    self.mapView.addAnnotation(annotation)
                    let landmark = Landmark(id: document.data()["id"] as! String,
                                            name: document.data()["name"] as! String,
                                            address: document.data()["address"] as! String,
                                            city:  document.data()["city"] as! String,
                                            state:  document.data()["state"] as! String,
                                            zipcode: document.data()["zipcode"] as! String,
                                            country: document.data()["country"] as! String,
                                            type: document.data()["type"] as! String,
                                            latitude: document.data()["latitude"] as! String,
                                            longitude: document.data()["longitude"] as! String,
                                            image: document.data()["image"] as! String)
                    self.listOfLandmarks.listOfLandmarks.append(landmark)
                }
            }
        }
    }
    
    func downloadFunFacts(db: Firestore) {
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
                                          verificationFlag: document.data()["verificationFlag"] as! String,
                                          image: document.data()["imageName"] as! String,
                                          disputeFlag: document.data()["disputeFlag"] as! String,
                                          submittedBy: document.data()["submittedBy"] as! String,
                                          dateSubmitted: document.data()["dateSubmitted"] as! String,
                                          source: document.data()["source"] as! String)
                    self.listOfFunFacts.listOfFunFacts.append(funFact)
                }
            }
        }
    }
    
    func addDataToFirestore(db: Firestore) {
        db.collection("landmarks").document("L0000000002").setData([
            "id": "L0000000002",
            "name": "Henry Hall",
            "address": "515 W 38th St",
            "city": "New York",
            "state": "NY",
            "zipcode": "10018",
            "country": "US",
            "type": "Apartment",
            "latitude": "40.7576393",
            "longitude": "-73.99792409999998"
        ])
        db.collection("landmarks").document("L0000000001").setData([
            "id": "L0000000001",
            "name": "Empire State Building",
            "address": "350 5th Ave",
            "city": "New York",
            "state": "NY",
            "zip": "10118",
            "country": "US",
            "type": "Landmark",
            "latitude": "40.748534",
            "longitude": "-73.985637"
        ]){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func addDataToFirestoreForLandmark(db: Firestore, documentID: String) {
        db.collection("funFacts").document(documentID + "-001").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-001",
            "description": "In the late-1920s, as New York’s economy boomed like never before, builders were in a mad dash to erect the world’s largest skyscraper. The main competition was between 40 Wall Street’s Bank of Manhattan building and the Chrysler Building. When completed in 1931, the colossus loomed 1,250 feet over the streets of Midtown Manhattan. It would remain the world’s tallest building for nearly 40 years until the completion of the first World Trade Center tower in 1970.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-001",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 12, 2018",
            "source": "https://www.history.com/news/10-surprising-facts-about-the-empire-state-building"
            ])
        db.collection("funFacts").document(documentID + "-002").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-002",
            "description": "It was modeled after two earlier buildings. Architect William Lamb of the firm Shreve, Lamb and Harmon is said to have modeled the Empire State Building after Winston-Salem, North Carolina’s Reynolds Building and Carew Tower in Cincinnati",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-002",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 12, 2018",
            "source": "https://www.history.com/news/10-surprising-facts-about-the-empire-state-building"
            ])
        db.collection("funFacts").document(documentID + "-003").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-003",
            "description": "The building was finished in record time. Despite the colossal size of the project, the design, planning and construction of the Empire State Building took just 20 months from start to finish",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-003",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 12, 2018",
            "source": "https://www.history.com/news/10-surprising-facts-about-the-empire-state-building"
            ])
        db.collection("funFacts").document(documentID + "-004").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-004",
            "description": "Its upper tower was originally designed as a mooring mast for airships. Convinced that transatlantic airship travel was the wave of the future, the building’s owners originally constructed the mast as a docking port for lighter-than-air dirigibles",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-004",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 12, 2018",
            "source": "https://www.history.com/news/10-surprising-facts-about-the-empire-state-building"
            ])
        db.collection("funFacts").document(documentID + "-005").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-005",
            "description": "The Empire State Building got off to a rocky start thanks to the 1929 stock market crash and the onset of the Great Depression. Less than 25 percent of the building’s retail space was occupied upon its opening in 1931, earning it the nickname the “Empty State Building”",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-005",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 12, 2018",
            "source": "https://www.history.com/news/10-surprising-facts-about-the-empire-state-building"
            ])
        db.collection("funFacts").document(documentID + "-006").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-006",
            "description": "On the morning of July 28, 1945, while flying an Army B-25 bomber toward New York’s La Guardia Airport, Army Lt. Col. William F. Smith became disoriented in heavy fog and drifted over Midtown Manhattan. The World War II combat veteran managed to dodge several skyscrapers, but he was unable to avoid plowing into the 78th and 79th floors of the Empire State at 200 miles an hour",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-006",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 12, 2018",
            "source": "https://www.history.com/news/10-surprising-facts-about-the-empire-state-building"
            ])
        db.collection("funFacts").document(documentID + "-007").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-007",
            "description": "A woman survived a 75-story plunge in one of the building’s elevators. During the 1945 bomber crash, several pieces of the B-25’s engine sliced through the Empire State Building and entered an elevator shaft. The cables for two cars were severed, including one containing a 19-year-old elevator operator named Betty Lou Oliver. The elevator plummeted from the 75th floor and soon crashed into the subbasement, but luckily for Oliver, more than a thousand feet of severed elevator cable had gathered at the bottom of the shaft, cushioning the blow",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-007",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 12, 2018",
            "source": "https://www.history.com/news/10-surprising-facts-about-the-empire-state-building"
            ])
        db.collection("funFacts").document(documentID + "-008").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-008",
            "description": "In 2011, Cornell researchers analyzed millions of Flickr photos and concluded that the Empire State Building is the most photographed building in the world. Remember to tag your shots #L0000000001-00Building.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-008",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-009").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-009",
            "description": "Static electricity gathers at high heights, and under the right atmospheric conditions, couples can experience a slight electric shock when they kiss.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-009",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-010").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-010",
            "description": "New York can look pretty tiny from all the way up here, but not as tiny as The New York City Panorama, built for the 1964 World's Fair. Compare the views at the Queens museum.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-010",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-011").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-011",
            "description": "On a clear day you can see five states from our Observatories: New York, New Jersey, Pennsylvania, Connecticut and Massachusetts.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-011",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-012").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-012",
            "description": "The top of the Empire State Building is used for broadcasting the majority of commercial TV stations and FM radio stations in New York City.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-012",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-013").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-013",
            "description": "The Empire State Building is home to so many businesses that it has its own zip code: 10118.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-013",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-014").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-014",
            "description": "In a 2007 poll conducted by the American Institute of Architects, the Empire State Building was named “America’s Favorite Architecture,” ahead of even The White House.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-014",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-015").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-015",
            "description": "The Empire State Building is the tallest LEED certified building in the United States.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-015",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-016").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-016",
            "description": "The Empire State Building lobby is one of the few interiors in New York to be designated a historic landmark by the Landmarks Preservation Commission.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-016",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
            ])
        db.collection("funFacts").document(documentID + "-017").setData([
            "landmarkId": "L0000000001",
            "id": "L0000000001-017",
            "description": "The American Society of Civil Engineers named the Empire State Building one of the Seven Wonders of the Modern World. View the official list.",
            "likes": "1",
            "dislikes": "0",
            "verificationFlag": "Y",
            "imageName": "L0000000001-017",
            "disputeFlag": "N",
            "submittedBy": "rushidolas",
            "dateSubmitted": "JULY 13, 2018",
            "source": "http://www.esbnyc.com/fun-facts"
        ]){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}
extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        let annotation = view.annotation as! FunFactAnnotation
        if let view = view as? MKPinAnnotationView {
            view.pinTintColor = UIColor.gray
        }
        print (annotation.landmarkID)
        setupBottomView(annotationClicked: annotation)
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

