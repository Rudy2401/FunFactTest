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
    var funFactPageVC: FunFactPageViewController!
    var contentVC: ContentViewController!

    let funFactDesc = "A famous bar in the West Village, the White Horse Tavern was the preferred drinking location of esteemed poet and writer Dylan Thomas, who passed away in 1953 from unconfirmed causes. Because he spent time at the White Horse Tavern, Thomas became the first of many artists and writers to gain inspiration from its walls."
    let imageCapText = "Credit: https://www.abqjew.net/2015/08/those-were-days.html"

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

        funFactPageVC = storyboard.instantiateViewController(withIdentifier: "funFactPage") as? FunFactPageViewController
        let funFact = FunFact(landmarkId: "NYpsvgl7hf4C7O0Ft7od",
                landmarkName: "White Horse Tavern",
                id: "2t4cWYo39iglxT0S858b",
                description: funFactDesc,
                funFactTitle: "",
                likes: 1,
                dislikes: 0,
                verificationFlag: "Y",
                image: "2t4cWYo39iglxT0S858b",
                imageCaption: imageCapText,
                disputeFlag: "N",
                submittedBy: "aSh5Z3KlHPd7hnOwfWtWomT5NF22",
                dateSubmitted: Timestamp(date: Date()),
                source: "https://kwnyc.com/blog/10-fun-facts-about-nycs-west-village-neighborhood/",
                tags: ["westvillage"],
                approvalCount: 0,
                rejectionCount: 0,
                approvalUsers: [],
                rejectionUsers: [],
                rejectionReason: [])
        let funFacts = [funFact]
        let pageContent = ["2t4cWYo39iglxT0S858b"]
        funFactPageVC.pageContent = pageContent as NSArray
        funFactPageVC.funFacts = funFacts
        funFactPageVC.headingContent = "58 Joralemon St"
        funFactPageVC.landmarkID = "NYpsvgl7hf4C7O0Ft7od"
        funFactPageVC.address = "58 Joralemon St"
        funFactPageVC.loadViewIfNeeded()

        contentVC = storyboard.instantiateViewController(withIdentifier: "contentView") as? ContentViewController
        contentVC.funFact = funFacts[0]
        contentVC.address = "58 Joralemon St"
        contentVC.landmarkID = "NYpsvgl7hf4C7O0Ft7od"
        contentVC.currPageNumberText = "1"
        contentVC.totalPageNumberText = "1"
        contentVC.loadViewIfNeeded()
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

    func testFunFactPageView() {
        XCTAssertNotNil(funFactPageVC)
        XCTAssertEqual("58 Joralemon St", funFactPageVC.navigationItem.title)
        XCTAssertEqual(1, funFactPageVC.totalPages)
    }

    func testContentView() {
        XCTAssertNotNil(contentVC)
        XCTAssertEqual("1", contentVC.currPageNumberText)
        XCTAssertEqual(funFactDesc, contentVC.funFact.description)
        XCTAssertEqual(imageCapText, contentVC.imageCaptionLabel.attributedText?.string)
    }
}
