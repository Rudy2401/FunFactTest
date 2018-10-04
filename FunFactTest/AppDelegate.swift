//
//  AppDelegate.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/20/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import CoreLocation
import UserNotifications
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var notificationCenter: UNUserNotificationCenter?
    var notificationCount = 0
    var listOfLandmarks = ListOfLandmarks(listOfLandmarks: [])
    var listOfFunFacts = ListOfFunFacts(listOfFunFacts: [])

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        FirebaseApp.configure()
        // Configure Facebook Sign in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Configure Google Sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // get the singleton object
        self.notificationCenter = UNUserNotificationCenter.current()
        
        // register as it's delegate
        notificationCenter?.delegate = self
        
        // define what do you need permission to use
        let options: UNAuthorizationOptions = [.alert, .sound]
        
         //request permission
        notificationCenter?.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }
        
        let db = Firestore.firestore()
        downloadLandmarks(db)
        downloadFunFacts(db)
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        
        if url.absoluteString.contains("fb") {
            handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
            
        } else {
            handled = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        
        return handled
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
//                    self.setupGeoFences(lat: Double(document.data()["latitude"] as! String)!,
//                                        lon: Double(document.data()["longitude"] as! String)!,
//                                        title: document.data()["name"] as! String,
//                                        landmarkID: document.data()["id"] as! String)
                    let source = (querySnapshot?.metadata.isFromCache)! ? "local cache" : "server"
                    print("Metadata: Data fetched from \(source)")
                }
            }
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
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
                content.body = funFact.description
                
                let imageName = "\(funFact.image).jpeg"
                let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
                if imageFromCache != nil {
                    let imageData = imageFromCache!.jpegData(compressionQuality: 1.0)
                    guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "\(funFact.image).jpeg", data: imageData! as NSData, options: nil) else { return  }
                    content.attachments = [attachment]
                    break
                } else {
                    let s = funFact.id
                    let imageName = "\(s).jpeg"
                    
                    let storage = Storage.storage()
                    let gsReference = storage.reference(forURL: "gs://funfacts-5b1a9.appspot.com/images/\(imageName)")
                    
                    gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error = \(error)")
                        } else {
                            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "\(funFact.image).jpeg", data: data! as NSData, options: nil) else { return  }
                            content.attachments = [attachment]
                        }
                    }
                    break
                }
            }
        }
        content.sound = UNNotificationSound.default
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

}
extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
//            handleEvent(forRegion: region)
        }
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
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is open and in foregroud
        completionHandler(.alert)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // get the notification identifier to respond accordingly
        let identifier = response.notification.request.identifier
        print ("identifier = \(identifier)")
        // do what you need to do
        
        // ...
    }
}
