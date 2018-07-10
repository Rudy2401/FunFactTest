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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var annotationBottomView: AnnotationBottomView!
    @IBOutlet var mapView: MKMapView!
    
    var currentLocationCoordinate = CLLocationCoordinate2D()
    // 1. create locationManager
    let locationManager = CLLocationManager()
    let util = Utils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
//        if let customFont = UIFont(name: "Arial", size: 30.0) {
//            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0), NSAttributedStringKey.font: customFont ]
//        }
        
        // 2. setup locationManager
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // 3. setup mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // 4. setup test data
        setupData()
    }
    func setupBottomView () {
        let numOffAttr = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                             NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 12.0)!
        ]
        
        
        
        let image = util.resizeImage(image: UIImage(named: "henryhall2")!, targetSize: CGSize(width: 200, height: 200))

        annotationBottomView.landmarkImage.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        annotationBottomView.landmarkImage = UIImageView(image: image)
        annotationBottomView.landmarkImage.clipsToBounds = true
        annotationBottomView.landmarkImage!.layer.cornerRadius = 5
//        annotationBottomView.landmarkImage!.layer.masksToBounds = true
        annotationBottomView.landmarkImage.contentMode = .scaleAspectFill
        
        annotationBottomView.addSubview(annotationBottomView.landmarkImage)
        annotationBottomView.landmarkImage.translatesAutoresizingMaskIntoConstraints = false
        
        annotationBottomView.landmarkImage.leadingAnchor.constraint(equalTo: annotationBottomView.leadingAnchor, constant: 10.0).isActive = true
        annotationBottomView.landmarkImage.topAnchor.constraint(equalTo: annotationBottomView.topAnchor, constant: 10.0).isActive = true
        annotationBottomView.landmarkImage.widthAnchor.constraint(equalToConstant: CGFloat(100)).isActive = true
        annotationBottomView.landmarkImage.heightAnchor.constraint(equalToConstant: CGFloat(100)).isActive = true
        annotationBottomView.translatesAutoresizingMaskIntoConstraints = false
        
        annotationBottomView.titleAnnotation.text = "Henry Hall"
        annotationBottomView.titleAnnotation.translatesAutoresizingMaskIntoConstraints = false
        annotationBottomView.titleAnnotation.leadingAnchor.constraint(equalTo: annotationBottomView.landmarkImage.trailingAnchor, constant: 10.0).isActive = true
        annotationBottomView.titleAnnotation.topAnchor.constraint(equalTo: annotationBottomView.topAnchor, constant: 10.0).isActive = true
        annotationBottomView.addSubview(annotationBottomView.titleAnnotation)
        
        annotationBottomView.landmarkType.text = "Apartment"
        annotationBottomView.landmarkType.translatesAutoresizingMaskIntoConstraints = false
        annotationBottomView.landmarkType.leadingAnchor.constraint(equalTo: annotationBottomView.landmarkImage.trailingAnchor, constant: 10.0).isActive = true
        annotationBottomView.landmarkType.topAnchor.constraint(equalTo: annotationBottomView.titleAnnotation.bottomAnchor, constant: 5.0).isActive = true
        annotationBottomView.addSubview(annotationBottomView.landmarkType)
        
        annotationBottomView.landmarkAddress.text = "515 W 38th St, New York, NY 10018"
        annotationBottomView.landmarkAddress.translatesAutoresizingMaskIntoConstraints = false
        annotationBottomView.landmarkAddress.leadingAnchor.constraint(equalTo: annotationBottomView.landmarkImage.trailingAnchor, constant: 10.0).isActive = true
        annotationBottomView.landmarkAddress.topAnchor.constraint(equalTo: annotationBottomView.landmarkType.bottomAnchor, constant: 5.0).isActive = true
        annotationBottomView.addSubview(annotationBottomView.landmarkAddress)
        
        let coordinate₁ = CLLocation(latitude: 40.7575956, longitude: -73.9983103)
        let distanceInMeters = CLLocation(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude).distance(from: coordinate₁)
        
        annotationBottomView.distance.text = String(format: "%.2f", distanceInMeters/1600) + " mi"
        annotationBottomView.distance.translatesAutoresizingMaskIntoConstraints = false
        annotationBottomView.distance.trailingAnchor.constraint(equalTo: annotationBottomView.trailingAnchor, constant: -10.0).isActive = true
        annotationBottomView.distance.topAnchor.constraint(equalTo: annotationBottomView.topAnchor, constant: 10.0).isActive = true
        annotationBottomView.addSubview(annotationBottomView.distance)
        
        annotationBottomView.likePercentage.font = UIFont.fontAwesome(ofSize: 12)
        annotationBottomView.likePercentage.textColor = UIColor.red
        
        let likePer = " 75%"
        
        let attrStringLikePer = NSAttributedString(string: likePer, attributes: numOffAttr)
        let likePerComplete = NSMutableAttributedString()
        likePerComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .heart)))
        likePerComplete.append(attrStringLikePer)
        annotationBottomView.likePercentage.attributedText = likePerComplete
        
        annotationBottomView.likePercentage.translatesAutoresizingMaskIntoConstraints = false
        annotationBottomView.likePercentage.leadingAnchor.constraint(equalTo: annotationBottomView.landmarkImage.trailingAnchor, constant: 10.0).isActive = true
        annotationBottomView.likePercentage.topAnchor.constraint(equalTo: annotationBottomView.landmarkAddress.bottomAnchor, constant: 5.0).isActive = true
        annotationBottomView.addSubview(annotationBottomView.likePercentage)
        
        annotationBottomView.numberOfFF.font = UIFont.fontAwesome(ofSize: 12)
        annotationBottomView.numberOfFF.textColor = UIColor.brown

        let numOfFF = " 2"
        
        let attrString = NSAttributedString(string: numOfFF, attributes: numOffAttr)
        let numOfFFComplete = NSMutableAttributedString()
        numOfFFComplete.append(NSAttributedString(string: String.fontAwesomeIcon(name: .book)))
        numOfFFComplete.append(attrString)
        annotationBottomView.numberOfFF.attributedText = numOfFFComplete
        
        annotationBottomView.numberOfFF.translatesAutoresizingMaskIntoConstraints = false
        annotationBottomView.numberOfFF.leadingAnchor.constraint(equalTo: annotationBottomView.likePercentage.trailingAnchor, constant: 20.0).isActive = true
        annotationBottomView.numberOfFF.topAnchor.constraint(equalTo: annotationBottomView.landmarkAddress.bottomAnchor, constant: 5.0).isActive = true
        annotationBottomView.addSubview(annotationBottomView.numberOfFF)
        
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        annotationBottomView.addGestureRecognizer(mytapGestureRecognizer)
        annotationBottomView.isUserInteractionEnabled = true
        
        mapView.addSubview(annotationBottomView)
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
    @objc func myTapAction(recognizer: UITapGestureRecognizer) {
        print ("Tapped")
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

            let image = util.resizeImage(image: UIImage(named: "henryhall")!, targetSize: CGSize(width: 70, height: 70))

            let funFactAnnotation = FunFactAnnotation(title: "Henry Hall",
                                                      address: "515 W 38th St, New York, NY 10018",
                                                      type: "Apartment",
                                                      coordinate: coordinate,
                                                      image: image,
                                                      pinColor: UIColor.blue)

            mapView.addAnnotation(funFactAnnotation)
            
            
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
        print ("In prepare for segue")
        //         Get the new view controller using segue.destinationViewController.
        //         Pass the selected object to the new view controller.
        let destinationVC = segue.destination as? FunFactPageViewController
        destinationVC?.pageContent = ["Henry Hall is the first of its kind - a community and a destination - like the boutique hotel you never want to leave or the members-only club where everyone’s welcome",
                                      "515 West 38th Street, the site of the former Legacy Recording Studio, is at the epicenter of Hudson Yards - where Henry Hall is redefining luxury for a new generation of New Yorkers."]
        destinationVC?.imageContent = ["henryhall", "henryhall2"]
        destinationVC?.submittedByContent = ["rushidolas", "dhwanishah"]
        destinationVC?.dateContent = ["JULY 2, 2018", "JULY 2, 2018"]
        destinationVC?.sourceContent = ["https://henryhallnyc.com/", "https://henryhallnyc.com/dfhasdkfhkasdhfkjhsadfksdhfjkdsh"]
        destinationVC?.likesContent = ["75% found this interesting", "45% found this interesting"]
        destinationVC?.headingContent = "Henry Hall"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = manager.location else{
            return
        }
        let currentLocationCoordinate = location.coordinate
        print(currentLocationCoordinate.latitude)
        print(currentLocationCoordinate.longitude)
        self.currentLocationCoordinate = currentLocationCoordinate
    }
    
}
extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        if let view = view as? MKPinAnnotationView {
            view.pinTintColor = UIColor.green
        }
        setupBottomView()
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




