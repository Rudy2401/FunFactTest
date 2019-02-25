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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var notificationCenter: UNUserNotificationCenter!
    var notificationCount = 0
    var manager: AlgoliaManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        // Configure Facebook Sign in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Configure Google Sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        self.locationManager.delegate = self
        // get the singleton object
        notificationCenter = UNUserNotificationCenter.current()
        
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
    func handleEvent(forRegion region: CLRegion!) {
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
            .order(by: "likes", descending: true)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print ("Error getting document \(error)")
                } else {
                    let document = snapshot?.documents.randomElement()
                    content.body = document?.data()["description"] as! String
                    imageId = document?.data()["imageName"] as! String
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
