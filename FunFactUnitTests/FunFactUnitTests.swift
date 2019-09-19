//
//  FunFactUnitTests.swift
//  FunFactUnitTests
//
//  Created by Rushi Dolas on 8/28/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import XCTest
import Firebase
import MapKit
@testable import FunFactTest

class FunFactUnitTests: XCTestCase {
    var storyboard: UIStoryboard!
    var welcomeVC: WelcomeViewController!
    var mainVC: MainViewController!
    var tabBarVC: TabBarController!
    var profileVC: ProfileViewController!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        welcomeVC = storyboard.instantiateViewController(withIdentifier: "welcome") as? WelcomeViewController
        welcomeVC.loadViewIfNeeded()
        
        tabBarVC = storyboard.instantiateViewController(withIdentifier: "tabBar") as? TabBarController
        tabBarVC.loadViewIfNeeded()
        
        mainVC = storyboard.instantiateViewController(withIdentifier: "mainView") as? MainViewController
        mainVC?.loadViewIfNeeded()
        
        profileVC = storyboard.instantiateViewController(withIdentifier: "profileView") as? ProfileViewController
        profileVC.loadViewIfNeeded()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFirstScreenIsWelcomeScreen() {
        XCTAssertEqual("Welcome to the World of Fun Facts!", welcomeVC.welcomeTitle!.text!)
        XCTAssertEqual(50, welcomeVC.googleSignInButton.frame.height)
        XCTAssertEqual(335, welcomeVC.googleSignInButton.frame.width)
        XCTAssertEqual(50, welcomeVC.fbSignInButton.frame.height)
        XCTAssertEqual(335, welcomeVC.fbSignInButton.frame.width)
        XCTAssertEqual(50, welcomeVC.emailSignInButton.frame.height)
        XCTAssertEqual(335, welcomeVC.emailSignInButton.frame.width)
        XCTAssertEqual(50, welcomeVC.guestButton.frame.height)
        XCTAssertEqual(335, welcomeVC.guestButton.frame.width)
    }
    
    func testMainScreen() {
        XCTAssertNotNil(mainVC)
        
        let exp = expectation(description: "Test after 2 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 2.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(1, mainVC?.navigationItem.rightBarButtonItems?.count)
            XCTAssertTrue((mainVC?.addFactButton.isEnabled)!)
            XCTAssertTrue((mainVC?.mapSearchButton.isEnabled)!)
            XCTAssertTrue((mainVC?.currentLocationButton.isEnabled)!)
            XCTAssertEqual(0.0, mainVC?.annotationBottomView.alpha)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testMapView() {
        XCTAssertNotNil(mainVC?.mapView)
        
        let exp = expectation(description: "Test after 2 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 2.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue((mainVC?.mapView.annotations.count)! > 0)
            XCTAssertTrue((mainVC?.mapView.annotations.count)! <= 30)
            for annotation in (mainVC?.mapView.annotations)! {
                if annotation is MKUserLocation {
                    continue
                }
                let ann = annotation as! FunFactAnnotation
                XCTAssertNotNil(ann.title)
                XCTAssertNotEqual("", ann.title)
                XCTAssertNotNil(ann.type)
                XCTAssertNotEqual("", ann.type)
                XCTAssertNotNil(ann.address)
                XCTAssertNotEqual("", ann.address)
                XCTAssertNotNil(ann.coordinate)
                XCTAssertNotNil(ann.landmarkID)
                XCTAssertNotEqual("", ann.landmarkID)
                mainVC.performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
            }
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testTabBar() {
        XCTAssertNotNil(tabBarVC)
        XCTAssertEqual(4, tabBarVC.tabBar.items?.count)
        
        for i in 0...3 {
            XCTAssertTrue((tabBarVC.tabBar.items?[i].isEnabled)!)
        }
        
        XCTAssertEqual("Home", tabBarVC.tabBar.items?[0].title)
        XCTAssertEqual("Profile", tabBarVC.tabBar.items?[1].title)
        XCTAssertEqual("Settings", tabBarVC.tabBar.items?[2].title)
        XCTAssertEqual("Search", tabBarVC.tabBar.items?[3].title)
    }
    
    func testProfileView() {
        XCTAssertNotNil(profileVC)
        XCTAssertFalse(profileVC.signInButton.isHidden)
        XCTAssertFalse(profileVC.signOutButton.isHidden)
        XCTAssertTrue(profileVC.editButtonItem.isEnabled)
        
        XCTAssertTrue(profileVC.disputesNum.isUserInteractionEnabled)
        XCTAssertTrue(profileVC.submittedNum.isUserInteractionEnabled)
        XCTAssertTrue(profileVC.rejectedNum.isUserInteractionEnabled)
        XCTAssertTrue(profileVC.verifiedNum.isUserInteractionEnabled)
        
        XCTAssertNotNil(profileVC.userImageView)
    }
    
    func testAnnotationClick() {
        
    }
}
