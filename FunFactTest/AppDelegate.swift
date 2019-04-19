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
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Configure Google Sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
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
        return true
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
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleDynamicLink(dynamicLink)
            return true
        } else if url.absoluteString.contains("fb") {
            handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
            
        } else if url.absoluteString.contains("google") {
            handled = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        return handled
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let incomingURL = userActivity.webpageURL {
            print ("Incoming URL = \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    print ("Found an error \(error!.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleDynamicLink(dynamicLink)
                }
            }
            if linkHandled {
                return true
            } else {
                return false
            }
        }
        return false
    }
    func handleDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print ("No URL")
            return
        }
        AppDataSingleton.appDataSharedInstance.url = url
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
        print ("NotificationCount = \(UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationCount))")
        print ("NotificationFrequency = \(UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationFrequency))")
        if UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationCount) >= UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationFrequency) {
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
                        content.body = document.data()["description"] as! String
                        imageId = document.data()["imageName"] as! String
                    } else {
                        return
                    }
                }
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
                            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: imageName, data: data! as NSData, options: nil) else { return  }
                            content.attachments = [attachment]
                            content.sound = UNNotificationSound.default
                            self.notificationCount += 1
                            
                            // when the notification will be triggered
                            let timeInSeconds: TimeInterval = 3
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
                                        if UserDefaults.standard.string(forKey: SettingsUserDefaults.notificationDate) == nil {
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "yyyy-MM-dd"
                                            let now = Date()
                                            let dateString = formatter.string(from:now)
                                            UserDefaults.standard.set(dateString, forKey: SettingsUserDefaults.notificationDate)
                                        } else {
                                            let notificationDate = UserDefaults.standard.string(forKey: SettingsUserDefaults.notificationDate)
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "yyyy-MM-dd"
                                            let now = Date()
                                            let todayDate = formatter.string(from:now)
                                            
                                            if notificationDate == todayDate {
                                                var count = UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationCount)
                                                count += 1
                                                UserDefaults.standard.set(count, forKey: SettingsUserDefaults.notificationCount)
                                            } else {
                                                UserDefaults.standard.set(todayDate, forKey: SettingsUserDefaults.notificationDate)
                                            }
                                        }
                                    }
                                })
                            })
                        }
                    }
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
        print ("identifier = \(identifier)")
    }
}
