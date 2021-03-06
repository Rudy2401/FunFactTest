//
//  AppDelegate.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/20/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import CoreLocation
import UserNotifications
import IQKeyboardManagerSwift
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseDynamicLinks
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GeoFirestoreManagerDelegate {
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var notificationCenter: UNUserNotificationCenter!
    var notificationCount = 0
    var manager: AlgoliaManager!
    var geofirestore: GeoFirestoreManager!
    var megaRegion: CLCircularRegion?
    
    override init() {
        super.init()
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "com.rushi.FunFact"
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        geofirestore = GeoFirestoreManager()
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Facebook Sign in
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        // Configure Google Sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // Google Ads initializer
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        setupLocationManager()
        
        // get the singleton object
        notificationCenter = UNUserNotificationCenter.current()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(calendarDayDidChange(_ :)),
                                               name: Notification.Name.NSCalendarDayChanged,
                                               object: nil)

        // define what do you need permission to use
        let options: UNAuthorizationOptions = [.alert, .sound]
        notificationCenter.delegate = self
        
        //Algolia instantiate
        manager = AlgoliaManager.sharedInstance
        
         //request permission
        notificationCenter?.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }
        //Enabling IQKeyboard manager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [SignUpViewController.self, SignInViewController.self]
        
        if UserDefaults.standard.object(forKey: SettingsUserDefaults.notificationDate) == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let now = Date()
            let dateString = formatter.string(from:now)
            UserDefaults.standard.set(dateString, forKey: SettingsUserDefaults.notificationDate)
        }
        return true
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .denied:
            print ("Denied")
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted:
            print ("Restricted")
        @unknown default:
            print ("Default")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        application.applicationIconBadgeNumber = 0
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        print ("Received url through custom URL scheme \(url.absoluteString)")
        if url.absoluteString.contains("funfactsproject") {
            handled =  handleURL(url)
        }
        else if url.absoluteString.contains("fb") {
            handled = ApplicationDelegate.shared.application(app, open: url, options: options)
            
        } else if url.absoluteString.contains("google") {
            handled = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        return handled
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let incomingURL = userActivity.webpageURL {
            return handleURL(incomingURL)
        }
        return false
    }
    func handleURL(_ url: URL) -> Bool {
        AppDataSingleton.appDataSharedInstance.url = url
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstNav = storyboard.instantiateViewController(withIdentifier: "firstNav") as! UINavigationController
        let nav1 = storyboard.instantiateViewController(withIdentifier: "nav1") as! UINavigationController
        let nav2 = storyboard.instantiateViewController(withIdentifier: "nav2") as! UINavigationController
        let nav3 = storyboard.instantiateViewController(withIdentifier: "nav3") as! UINavigationController
        let nav4 = storyboard.instantiateViewController(withIdentifier: "nav4") as! UINavigationController
        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainView") as! MainViewController
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBar") as! TabBarController
        nav1.viewControllers = [mainVC]
        tabBarController.viewControllers = [nav1, nav2, nav3, nav4]
        self.window?.rootViewController = firstNav
        firstNav.show(tabBarController, sender: nil)
        return true
    }
    
    @objc func calendarDayDidChange(_ notification : NSNotification) {
        UserDefaults.standard.set(0, forKey: "NotificationCount")
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion && region != megaRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region == megaRegion {
            megaRegion = nil
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        if megaRegion != nil && (megaRegion?.contains(lastLocation.coordinate))! {
            return
        }
        megaRegion = CLCircularRegion(center: lastLocation.coordinate, radius: 800, identifier: "megaRegion")
        megaRegion?.notifyOnExit = true
        megaRegion?.notifyOnEntry = false
        locationManager.startMonitoring(for: megaRegion!)
        
        stopMonitoringRegions()
        geofirestore.getLandmarks(from: lastLocation, radius: 800) { (landmark, error, count) in
            if let error = error {
                print ("Error getting data from GeoFirestore \(error)")
            } else {
                let landmark = landmark!
                self.setupGeoFences(lat: landmark.coordinates.latitude,
                                    lon: landmark.coordinates.longitude,
                                    title: landmark.name,
                                    landmarkID: landmark.id)
                
            }
        }
    }
    func setupGeoFences(lat: Double, lon: Double, title: String, landmarkID: String) {
        // 1. check if system can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            // 2. region data
            let regionRadius = 50.0
            
            let identifier = landmarkID + "|" + title
            // 3. setup region
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat,
                                                                         longitude: lon),
                                          radius: regionRadius,
                                          identifier: identifier)
            
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
        } else {
            print("System can't track regions")
        }
    }
    func stopMonitoringRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
    func handleEvent(forRegion region: CLRegion!) {
        let notificationDate = UserDefaults.standard.string(forKey: SettingsUserDefaults.notificationDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let todaysDate = formatter.string(from: now)
        
        if UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationCount)
            >= UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationFrequency) && todaysDate == notificationDate {
            return
        }
        if !region.identifier.contains("|") {
            return
        }
        // customize your notification content
        let db = Firestore.firestore()
        let title = region.identifier.components(separatedBy: "|").last
        let landmarkID = region.identifier.components(separatedBy: "|").first
        let content = UNMutableNotificationContent()
        var imageId = ""
        content.title = "NEAR " + title!.uppercased() + "?"
        content.subtitle = "Did you know?"
        
        db.collection("funFacts")
            .whereField("landmarkId", isEqualTo: landmarkID!)
            .whereField("verificationFlag", isEqualTo: "Y")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print ("Error getting document \(error)")
                } else {
                    if let document = snapshot?.documents.randomElement(), document.exists {
                        let notificationContent = (document.data()["funFactTitle"] as! String).replacingOccurrences(of: " ", with: "") == ""
                            ? (document.data()["description"] as! String)
                            : (document.data()["funFactTitle"] as! String) + "\n" + (document.data()["description"] as! String)
                        
                        content.body = notificationContent
                        imageId = document.data()["imageName"] as! String
                        
                        // Add image to notification
                        let imageName = "\(imageId).jpeg"
                        let imageFromCache = CacheManager.shared.getFromCache(key: imageId) as? UIImage
                        if imageFromCache != nil {
                            let imageData = imageFromCache!.jpegData(compressionQuality: 1.0)
                            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: imageName, data: imageData! as NSData, options: nil) else { return  }
                            content.attachments = [attachment]
                        } else {
                            let storage = Storage.storage()
                            let storageRef = storage.reference()
                            let gsReference = storageRef.child("images/\(imageName)")
                            gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("error = \(error)")
                                } else {
                                    self.createDynamicLink(landmarkID: landmarkID ?? "", funFactID: document.data()["id"] as! String, completion: { (identifier, error) in
                                        if let error = error {
                                            print ("Error creating dynamic link \(error)")
                                        } else {
                                            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: imageName, data: data! as NSData, options: nil) else { return  }
                                            content.attachments = [attachment]
                                            content.sound = UNNotificationSound.default
                                            self.notificationCount += 1
                                            
                                            // when the notification will be triggered
                                            let timeInSeconds: TimeInterval = 2
                                            // the actual trigger object
                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
                                                                                            repeats: false)
                                            // notification unique identifier, dynamic link will be the identifier
                                            let identifier = identifier!
                                            
                                            // the notification request object
                                            let request = UNNotificationRequest(identifier: identifier,
                                                                                content: content,
                                                                                trigger: trigger)
                                            // trying to add the notification request to notification center
                                            self.notificationCenter.getDeliveredNotifications(completionHandler: { (notifications) in
                                                // MARK: This portion is commented to receive multiple notifications for one landmark
                                                /*for notification in notifications {
                                                 if notification.request.identifier == identifier {
                                                 print (notification.request.identifier)
                                                 return
                                                 }
                                                 }*/
                                                self.notificationCenter?.add(request, withCompletionHandler: { (error) in
                                                    if error != nil {
                                                        print("Error adding notification with identifier: \(identifier) \(error?.localizedDescription ?? "")")
                                                    } else {
                                                        if notificationDate == todaysDate {
                                                            var count = UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationCount)
                                                            count += 1
                                                            UserDefaults.standard.set(count, forKey: SettingsUserDefaults.notificationCount)
                                                        } else {
                                                            UserDefaults.standard.set(todaysDate, forKey: SettingsUserDefaults.notificationDate)
                                                            UserDefaults.standard.set(0, forKey: SettingsUserDefaults.notificationCount)
                                                        }
                                                    }
                                                })
                                            })
                                        }
                                    })
                                }
                            }
                        }
                    } else {
                        return
                    }
                }
        }
    }
    func createDynamicLink(landmarkID: String, funFactID: String, completion: @escaping (String?, String?) -> ()) {
        guard let link = URL(string: "https://funfactsproject/?efr=1&landmarkID=\(landmarkID)&funFactID=\(landmarkID)&apn=com.rushi.FunFact&d=1") else { return }
        let dynamicLinksDomainURIPrefix = "https://funfactsproject.page.link"
        
        let linkBuilder = DynamicLinkComponents(link: link,
                                                domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.rushi.FunFact")
        
        guard let longDynamicLink = linkBuilder?.url else { return }
        print("The long URL is: \(longDynamicLink)")
        DynamicLinks.performDiagnostics(completion: nil)
        
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .short
        linkBuilder?.options = options
        
        linkBuilder?.shorten { url, warnings, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                let shortUrl = url!
                print("The short URL is: \(shortUrl.absoluteString)")
                completion(shortUrl.absoluteString, nil)
            }
        }
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is open and in foregroud
        completionHandler(.alert)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // get the notification identifier to respond accordingly
        let identifier = response.notification.request.identifier
        print ("Ciicked on notification! Link: \(identifier)")
        let _ = handleURL(URL(string: identifier)!)
    }
}
extension UIApplication {
    var visibleViewController : UIViewController? {
        return keyWindow?.rootViewController?.topViewController
    }
}

extension UIViewController {
    fileprivate var topViewController: UIViewController {
        switch self {
        case is UINavigationController:
            return (self as! UINavigationController).visibleViewController?.topViewController ?? self
        case is UITabBarController:
            return (self as! UITabBarController).selectedViewController?.topViewController ?? self
        default:
            return presentedViewController?.topViewController ?? self
        }
    }
}
