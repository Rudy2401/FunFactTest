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


class MainViewController: UIViewController, FirestoreManagerDelegate {
    
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
    var landmarkImage = UIImage()
    var annotations: [FunFactAnnotation]?
    var landmarkType = ""
    var userProfile = UserProfile(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, verifiedCount: 0, rejectedCount: 0, email: "", name: "", userName: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [], funFactsVerified: [], funFactsRejected: [])
    var boundingBox: GeoRect?
    var firestore = FirestoreManager()
    
    // 1. create locationManager
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeColor.layer.cornerRadius = 2.5
        firestore.delegate = self
        
        annotationBottomView.alpha = 0.0
        setupNavigationbar()
        
        // 2. setup locationManager
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        firestore.downloadUserProfile(Auth.auth().currentUser?.uid ?? "") { (user) in
            AppDataSingleton.appDataSharedInstance.userProfile = user
        }
        
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
    func documentsDidUpdate() {
        print ("uploaded to cache")
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
        var landmark = Landmark(id: "",
                                name: "",
                                address: "",
                                city: "",
                                state: "",
                                zipcode: "",
                                country: "",
                                type: "",
                                coordinates: GeoPoint(latitude: 0, longitude: 0),
                                image: "",
                                numOfFunFacts: 0,
                                likes: 0,
                                dislikes: 0 )
        
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
        
        let attrStringLikePer = NSAttributedString(string: likePer,
                                                   attributes: Attributes.attribute12RegDG)
        let likePerComplete = NSMutableAttributedString()
        likePerComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .heart)))
        likePerComplete.append(attrStringLikePer)
        likeLabel.attributedText = likePerComplete
        
        noOfFunFactsLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        noOfFunFactsLabel.textColor = UIColor.brown
        
        let numOfFF = " " + String (landmark.numOfFunFacts)
        
        let attrString = NSAttributedString(string: numOfFF,
                                            attributes: Attributes.attribute12RegDG)
        let numOfFFComplete = NSMutableAttributedString()
        numOfFFComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .file)))
        numOfFFComplete.append(attrString)
        noOfFunFactsLabel.attributedText = numOfFFComplete
        
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                            action: #selector(viewFunFactDetailPage))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        annotationBottomView.addGestureRecognizer(mytapGestureRecognizer)
        annotationBottomView.isUserInteractionEnabled = true
        
        setView(view: annotationBottomView,  alpha: 1.0)
        
        let mapViewGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(mapViewTap))
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
        let imageId = funFact.image
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            // Put your code which should be executed with a delay here
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
    
    @objc func viewFunFactDetailPage(recognizer: UITapGestureRecognizer) {
        let db = Firestore.firestore()
        downloadFunFactsAndSegue(for: landmarkID, db: db)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromFirestoreAndAddAnnotations() {
        //4. Getting data from Firestore
        downloadLandmarks(caller: "viewDidLoad")
        firestore.downloadImagesIntoCache()
    }
    func setupGeoFences(lat: Double, lon: Double, title: String, landmarkID: String) {
        // 1. check if system can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            // 2. region data
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let regionRadius = 100.0
            
            let identifier = landmarkID + "|" + title
            // 3. setup region
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat,
                                                                         longitude: lon),
                                          radius: regionRadius,
                                          identifier: identifier)
            
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
            
            // 5. setup circle
            let circle = MKCircle(center: coordinate, radius: regionRadius)
            mapView.addOverlay(circle)
        } else {
            print("System can't track regions")
        }
    }
    //     MARK: - Navigation
    //
    //     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
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
