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
import InstantSearch
import Geofirestore
import FirebaseDynamicLinks

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
    @IBOutlet weak var mapSearchButton: UIButton!
    
    
    var landmarkTitle = ""
    var landmarkID = ""
    var currentLocationCoordinate = CLLocationCoordinate2D()
    var landmarkImage = UIImage()
    var landmarkType = ""
    var boundingBox: GeoRect?
    var firestore = FirestoreManager()
    var currentAnnotation: FunFactAnnotation?
    
    // 1. create locationManager
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBarAppearance()
            navBar.backgroundColor = Colors.systemGreenColor
            navBar.titleTextAttributes = Attributes.navTitleAttribute
            navBar.largeTitleTextAttributes = Attributes.navTitleAttribute
            
            self.navigationController?.navigationBar.standardAppearance = navBar
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBar
        } else {
            navigationController?.navigationBar.backgroundColor = Colors.seagreenColor
        }
        view.accessibilityIdentifier = "mapView"
        typeColor.layer.cornerRadius = 2.5
        firestore.delegate = self
        annotationBottomView.alpha = 0.0
        
        addNavButtons()
        addButtonsToView()
        setupSettingsDefault()
        setupLocationManager()
        darkModeSupport()
        tabBarController?.delegate = (UIApplication.shared.delegate as! AppDelegate) as? UITabBarControllerDelegate
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showFunFact),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        let currentUserUID = Auth.auth().currentUser!.isAnonymous ? "" : Auth.auth().currentUser?.uid
        firestore.downloadUserProfile(currentUserUID ?? "") { (user, error) in
            if let error = error {
                print ("Error getting user profile \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.userProfile = user!
                self.populateLeaders()
            }
        }
        
        // setup mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        delay(1) {
            self.loadDataFromFirestoreAndAddAnnotations()
        }
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        darkModeSupport()
    }
    func darkModeSupport() {
        if traitCollection.userInterfaceStyle == .light {
            annotationBottomView.backgroundColor = .white
            titleAnnotationLabel.textColor = .black
            typeLabel.textColor = .black
            addressLabel.textColor = .black
        } else {
            if #available(iOS 13.0, *) {
                annotationBottomView.backgroundColor = .systemGray3
            } else {
                annotationBottomView.backgroundColor = .black
            }
            titleAnnotationLabel.textColor = .white
            typeLabel.textColor = .white
            addressLabel.textColor = .white
        }
    }
    
    func documentsDidUpdate() {
        print ("uploaded to cache")
    }
    
    func setupSettingsDefault() {
        if UserDefaults.standard.object(forKey: SettingsUserDefaults.notificationFrequency) == nil {
            UserDefaults.standard.set(7, forKey: SettingsUserDefaults.notificationFrequency)
        }
        if UserDefaults.standard.object(forKey: SettingsUserDefaults.directionsSetting) == nil {
            UserDefaults.standard.set(DirectionSetting.walk, forKey: SettingsUserDefaults.directionsSetting)
        }
    }
    
    func setupLocationManager() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined: // 1. status is not determined
            locationManager.requestAlwaysAuthorization()
        case .denied: // 2. authorization was denied
            let alert = UIAlertController(title: "Warning",
                                          message: "Location services were previously denied. Please enable location services for this app in Settings.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .authorizedAlways: // 3. we do have authorization
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse: // 3. we do have authorization
            locationManager.startUpdatingLocation()
        default:
            print ("default")
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func addButtonsToView() {
        currentLocationButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .light)
        currentLocationButton.setTitle(String.fontAwesomeIcon(name: .location), for: .normal)
        
        let addFactLabel = String.fontAwesomeIcon(name: .plus)
        let addFactLabelAttr = NSAttributedString(string: addFactLabel, attributes: Attributes.addFactButtonAttribute)
        let addFactLabelAttrClicked = NSAttributedString(string: addFactLabel, attributes: Attributes.toolBarImageClickedAttribute)
        
        addFactButton.accessibilityIdentifier = "addFactButton"
        addFactButton.backgroundColor = Colors.systemGreenColor
        addFactButton.clipsToBounds = true
        addFactButton.layer.cornerRadius = 25
        addFactButton.layer.shadowPath = UIBezierPath(roundedRect: addFactButton.bounds, cornerRadius: 25).cgPath
        addFactButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        addFactButton.layer.shadowOffset = CGSize(width: 0, height: 9)
        addFactButton.layer.shadowOpacity = 1.0
        addFactButton.layer.shadowRadius = 10.0
        addFactButton.layer.masksToBounds = false
        addFactButton.setAttributedTitle(addFactLabelAttr, for: .normal)
        addFactButton.setAttributedTitle(addFactLabelAttrClicked, for: .selected)
        addFactButton.setAttributedTitle(addFactLabelAttrClicked, for: .highlighted)
        addFactButton.titleLabel?.textAlignment = .center
        
        let currentLocationLabel = String.fontAwesomeIcon(name: .locationArrow)
        let currentLocationAttr = NSAttributedString(string: currentLocationLabel, attributes: Attributes.currentLocationButtonAttribute)
        let currentLocationAttrClicked = NSAttributedString(string: currentLocationLabel, attributes: Attributes.toolBarImageClickedAttribute)
        
        currentLocationButton.backgroundColor = UIColor.clear
        currentLocationButton.clipsToBounds = true
        currentLocationButton.layer.cornerRadius = currentLocationButton.frame.height/2
        currentLocationButton.layer.shadowPath = UIBezierPath(roundedRect: currentLocationButton.bounds, cornerRadius: currentLocationButton.frame.height/2).cgPath
        currentLocationButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        currentLocationButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        currentLocationButton.layer.shadowOpacity = 1.0
        currentLocationButton.layer.shadowRadius = 10.0
        currentLocationButton.layer.masksToBounds = false
        currentLocationButton.setAttributedTitle(currentLocationAttr, for: .normal)
        currentLocationButton.setAttributedTitle(currentLocationAttrClicked, for: .selected)
        currentLocationButton.setAttributedTitle(currentLocationAttrClicked, for: .highlighted)
        currentLocationButton.titleLabel?.textAlignment = .center
        
        mapView.layoutMargins = UIEdgeInsets(top: 40, left: 0, bottom: 20, right: 0)
        if let coor = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coor, animated: true)
        }
        
        mapSearchButton.titleLabel?.font = UIFont(name: Fonts.regularFont, size: CGFloat(15))
        mapSearchButton.layer.backgroundColor = Colors.systemGreenColor.cgColor
        mapSearchButton.setTitle("Search this area", for: .normal)
        mapSearchButton.setTitle("Search this area", for: .highlighted)
        mapSearchButton.layer.cornerRadius = mapSearchButton.frame.height/2
        mapSearchButton.layer.shadowPath = UIBezierPath(roundedRect: mapSearchButton.bounds, cornerRadius: mapSearchButton.frame.height/2).cgPath
        mapSearchButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        mapSearchButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        mapSearchButton.layer.shadowOpacity = 1.0
        mapSearchButton.layer.shadowRadius = 10.0
        mapSearchButton.layer.masksToBounds = false
    }
    
    @IBAction func viewAddFact(_ sender: Any) {
        if Auth.auth().currentUser!.isAnonymous {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to submit a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        performSegue(withIdentifier: "addFactDetail", sender: self)
    }
    @IBAction func mapSearchAction(_ sender: Any) {
        AppDataSingleton.appDataSharedInstance.event = .mapEvent
        downloadLandmarks(caller: .mapEvent)
    }
    
    @IBAction func showCurrentLocation(_ sender: Any) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    func setupBottomView (annotationClicked: FunFactAnnotation, landmark: Landmark) {
        var bottomAttribute = Attributes.attribute12RegDG
        if annotationBottomView.isHidden == true {
            annotationBottomView.isHidden = false
        }
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
        typeColor.backgroundColor = Constants.getMarkerDetails(type: annotationClicked.type, width: 50, height: 50).color
        annotationBottomView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        annotationBottomView.layer.shadowOffset = CGSize(width: 0, height: 3)
        annotationBottomView.layer.shadowOpacity = 1.0
        annotationBottomView.layer.shadowRadius = 10.0
        annotationBottomView.layer.masksToBounds = false
        
        if traitCollection.userInterfaceStyle == .light {
            annotationBottomView.backgroundColor = .white
        } else {
            annotationBottomView.backgroundColor = .black
            bottomAttribute = Attributes.attribute12RegDGDark
            if #available(iOS 13.0, *) {
                annotationBottomView.backgroundColor = .systemGray3
            } else {
                annotationBottomView.backgroundColor = .black
            }
        }
        
        annotationBottomView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        annotationBottomView.layer.borderWidth = CGFloat.init(0.2)
        annotationBottomView.layer.borderColor = UIColor.lightGray.cgColor
        annotationBottomView.layer.cornerRadius = 5
        
        landmarkTitle = annotationClicked.title?.components(separatedBy: ") ").last ?? ""
        landmarkID = annotationClicked.landmarkID
        
        setupImage(landmark)
        
        titleAnnotationLabel.text = landmark.name
        typeLabel.text = landmark.type
        landmarkType = landmark.type
        addressLabel.text = ((landmark.address.replacingOccurrences(of: " ", with: "") == "") ? landmark.name : landmark.address) +
            ", " + landmark.city +
            ", " + landmark.state +
            ", " + landmark.zipcode
        let coordinate₁ = CLLocation(latitude: landmark.coordinates.latitude, longitude: landmark.coordinates.longitude) 
        let distanceInMeters = CLLocation(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude).distance(from: coordinate₁)
        
        distanceLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        distanceLabel.textColor = UIColor.systemBlue
        let distance = " " + String(format: "%.2f", distanceInMeters/1600) + " mi"
        let attrStringDist = NSAttributedString(string: distance, attributes: bottomAttribute)
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
                                                   attributes: bottomAttribute)
        let likePerComplete = NSMutableAttributedString()
        likePerComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .heart)))
        likePerComplete.append(attrStringLikePer)
        likeLabel.attributedText = likePerComplete
        
        noOfFunFactsLabel.font = UIFont.fontAwesome(ofSize: 12, style: .solid)
        noOfFunFactsLabel.textColor = UIColor.systemOrange
        
        let numOfFF = " " + String (landmark.numOfFunFacts)
        
        let attrString = NSAttributedString(string: numOfFF,
                                            attributes: bottomAttribute)
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
        
        // MARK: Draws direction path
        setupDirections(destCoordinates: CLLocationCoordinate2D(latitude: landmark.coordinates.latitude, longitude: landmark.coordinates.longitude))
    }
    func setupDirections(destCoordinates: CLLocationCoordinate2D) {
        var transportType = MKDirectionsTransportType()
        switch UserDefaults.standard.string(forKey: SettingsUserDefaults.directionsSetting) {
        case DirectionSetting.off:
            return
        case DirectionSetting.auto:
            transportType = .automobile
        case DirectionSetting.walk:
            transportType = .walking
        default:
            return
        }
        let sourcePlacemark = MKPlacemark(coordinate: currentLocationCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destCoordinates,
                                               addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = transportType
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
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
            gsReference.downloadURL { url, error in
                if let error = error {
                    print ("Error setting url \(error)")
                } else {
                    self.landmarkImageView.sd_setImage(with: url, placeholderImage: UIImage())
                }
            }
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
        setupNavigationbar()
        if currentAnnotation != nil {
            firestore.isLandmarkDeleted(landmarkID: currentAnnotation!.landmarkID) { (deleted) in
                if deleted == .yes {
                    self.mapView.removeAnnotation(self.currentAnnotation!)
                    self.annotationBottomView.isHidden = true
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showFunFact()
    }
    @objc func showFunFact() {
        if AppDataSingleton.appDataSharedInstance.url != nil {
            DynamicLinks.dynamicLinks().handleUniversalLink(AppDataSingleton.appDataSharedInstance.url!) { (dynamicLink, error) in
                guard error == nil else {
                    print ("Found an error \(error!.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    guard let landmarkID = dynamicLink.url?.valueOf("landmarkID") else { return }
                    self.downloadFunFactsAndSegue(for: landmarkID)
                    AppDataSingleton.appDataSharedInstance.url = nil
                }
            }
        }
    }
    @objc func viewAddFact(recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "addFactDetail", sender: self)
    }
    
    @objc func viewProfile(recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    @objc func viewFunFactDetailPage(recognizer: UITapGestureRecognizer) {
        downloadFunFactsAndSegue(for: landmarkID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromFirestoreAndAddAnnotations() {
        //4. Getting data from Firestore
        AppDataSingleton.appDataSharedInstance.event = .firstLoad
        self.downloadLandmarks(caller: .firstLoad)
    }
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func setupNavigationbar () {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Home"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func addNavButtons() {
        let leaderLabel1 = String.fontAwesomeIcon(name: .award)
        let leaderAttr1 = NSAttributedString(string: leaderLabel1, attributes: Attributes.navBarImageLightAttribute)
        let leaderAttrClicked1 = NSAttributedString(string: leaderLabel1, attributes: Attributes.navBarImageClickedAttribute)
        
        let completeleaderLabel = NSMutableAttributedString()
        completeleaderLabel.append(leaderAttr1)
        
        let completeleaderLabelClicked = NSMutableAttributedString()
        completeleaderLabelClicked.append(leaderAttrClicked1)
        
        let leader = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: self.view.frame.size.width / 10,
                                            height: self.view.frame.size.height))
        leader.isUserInteractionEnabled = true
        leader.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        leader.setAttributedTitle(completeleaderLabel, for: .normal)
        leader.setAttributedTitle(completeleaderLabelClicked, for: .highlighted)
        leader.setAttributedTitle(completeleaderLabelClicked, for: .selected)
        leader.titleLabel?.textAlignment = .center
        leader.addTarget(self, action: #selector(showLeaderPage), for: .touchUpInside)
        let leaderBtn = UIBarButtonItem(customView: leader)
        navigationItem.setRightBarButtonItems([leaderBtn], animated: true)
        leader.accessibilityIdentifier = "leaderBtn"
    }
    @objc func showLeaderPage(_ sender: Any) {
        performSegue(withIdentifier: "leaderboardSegue", sender: self)
    }
    func populateLeaders() {
        firestore.getLeaders(type: .country) { (leaders, error) in
            if let error = error {
                print ("Error getting leader data \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.leadersByCountry = leaders!
            }
        }
        firestore.getLeaders(type: .city) { (leaders, error) in
            if let error = error {
                print ("Error getting leader data \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.leadersByCity = leaders!
            }
        }
        firestore.getLeaders(type: .worldwide) { (leaders, error) in
            if let error = error {
                print ("Error getting leader data \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.leadersWorldwide = leaders!
            }
        }
    }
}
extension MainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        } else if view.annotation is MKClusterAnnotation {
            let center = CLLocationCoordinate2D(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
            print (mapView.region.span)
            if mapView.region.span.latitudeDelta > 0.011 && mapView.region.span.longitudeDelta > 0.011 {
                let region = MKCoordinateRegion(center: center,
                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapView.setRegion(region, animated: true)
            } else {
                let region = MKCoordinateRegion(center: center,
                                                span: MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta/2,
                                                                       longitudeDelta: mapView.region.span.longitudeDelta/2))
                self.mapView.setRegion(region, animated: true)
            }
        }
        
        if let annotation = view.annotation as? FunFactAnnotation {
            self.currentAnnotation = annotation
            firestore.getLandmark(for: annotation.landmarkID) { (landmark, error) in
                if let error = error {
                    print("Error getting landmark object \(error)")
                }
                else {
                    self.setupBottomView(annotationClicked: annotation, landmark: landmark!)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        if annotation is MKClusterAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation)
        }
        var annotationView = MKMarkerAnnotationView()
        annotationView.accessibilityLabel = "annotation"
        annotationView.isAccessibilityElement = true
        guard annotation is FunFactAnnotation else { return nil }
        
        let identifier = "annotation"
        var image = UIImage()
        var color = UIColor.red
        image = Constants.getMarkerDetails(type: (annotation as! FunFactAnnotation).type, width: 50, height: 50).image
        color = Constants.getMarkerDetails(type: (annotation as! FunFactAnnotation).type, width: 50, height: 50).color
        
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
        
//        if let tileOverlay = overlay as? MKTileOverlay {
//            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
//        } else {
//            return MKOverlayRenderer(overlay: overlay)
//        }
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = Colors.orangeColor
        renderer.lineWidth = 2.0
        
        return renderer
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
extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
