//
//  FunFactTestUITests.swift
//  FunFactTestUITests
//
//  Created by Rushi Dolas on 4/15/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import XCTest

class FunFactTestUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAllTabPages() {
        
        let app = XCUIApplication()
        app.navigationBars["Home"]/*@START_MENU_TOKEN@*/.buttons["leaderBtn"]/*[[".buttons[\"\"]",".buttons[\"leaderBtn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let leaderboardNavigationBar = app.navigationBars["Leaderboard"]
        leaderboardNavigationBar.otherElements["Leaderboard"].tap()
        app.buttons["Country"].tap()
        app.buttons["Worldwide"].tap()
        XCTAssertTrue(leaderboardNavigationBar.buttons["Home"].exists)
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Profile"].tap()
        app.navigationBars["User Profile"].otherElements["User Profile"].tap()
        
        let elementsQuery = app.scrollViews["profileScrollView"].otherElements
        elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["submittedNum"]/*[[".staticTexts[\"44\"]",".staticTexts[\"submittedNum\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let userSubmissionsNavigationBar = app.navigationBars["User Submissions"]
        XCTAssertTrue(userSubmissionsNavigationBar.staticTexts["User Submissions"].exists)
        userSubmissionsNavigationBar.buttons["User Profile"].tap()
        elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["disputesNum"]/*[[".staticTexts[\"0\"]",".staticTexts[\"disputesNum\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let userDisputesNavigationBar = app.navigationBars["User Disputes"]
        XCTAssertTrue(userDisputesNavigationBar.staticTexts["User Disputes"].exists)
        userDisputesNavigationBar.buttons["User Profile"].tap()
        elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["verifiedNum"]/*[[".staticTexts[\"4\"]",".staticTexts[\"verifiedNum\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let userVerificationsNavigationBar = app.navigationBars["User Verifications"]
        XCTAssertTrue(userVerificationsNavigationBar.staticTexts["User Verifications"].exists)
        userVerificationsNavigationBar.buttons["User Profile"].tap()
        elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["rejectedNum"]/*[[".staticTexts[\"2\"]",".staticTexts[\"rejectedNum\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let userRejectionsNavigationBar = app.navigationBars["User Rejections"]
        XCTAssertTrue(userRejectionsNavigationBar.staticTexts["User Rejections"].exists)
        userRejectionsNavigationBar.buttons["User Profile"].tap()
        tabBarsQuery.buttons["Settings"].tap()
        
        let settingstableTable = app.tables["settingsTable"]
        settingstableTable/*@START_MENU_TOKEN@*/.staticTexts["Choose your interests"]/*[[".cells.staticTexts[\"Choose your interests\"]",".staticTexts[\"Choose your interests\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let chooseYourInterestsNavigationBar = app.navigationBars["Choose your interests"]
        XCTAssertTrue(chooseYourInterestsNavigationBar.otherElements["Choose your interests"].exists)
        chooseYourInterestsNavigationBar.buttons["Settings"].tap()
        settingstableTable/*@START_MENU_TOKEN@*/.staticTexts["More Settings"]/*[[".cells.staticTexts[\"More Settings\"]",".staticTexts[\"More Settings\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let moreSettingsNavigationBar = app.navigationBars["More Settings"]
        XCTAssertTrue(moreSettingsNavigationBar.otherElements["More Settings"].exists)
        moreSettingsNavigationBar.buttons["Settings"].tap()
        tabBarsQuery.buttons["Search"].tap()
        app.buttons["Tags"].tap()
        app.buttons["People"].tap()
        tabBarsQuery.buttons["Home"].tap()
        
    }
    
    func testAddFact() {
        let app = XCUIApplication()
        app.buttons["addFactButton"].tap()
        
        let addNewFunFactNavigationBar = app.navigationBars["Add New Fun Fact"]
        XCTAssertTrue(addNewFunFactNavigationBar.otherElements["Add New Fun Fact"].exists)
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.pickerWheels["--- Select landmark type ---"].swipeUp()
        scrollViewsQuery.otherElements.containing(.staticText, identifier:"Choose image").element.swipeUp()
        scrollViewsQuery.otherElements.containing(.staticText, identifier:"Choose image").children(matching: .textView).element(boundBy: 1).tap()
        
        let enterSourceExampleHttpWwwHistoryComTextField = elementsQuery.textFields["Enter source (example: http://www.history.com)"]
        enterSourceExampleHttpWwwHistoryComTextField.tap()
        XCTAssertTrue(elementsQuery.buttons["submit"].exists)
        elementsQuery.buttons["submit"].tap()
        app.alerts["Error"].buttons["OK"].tap()
        addNewFunFactNavigationBar.buttons["Home"].tap()
        
    }
    
    func testAnnotationAndContent() {
        
        
        
    }
    
    //    func testExample() {
    //        // Use recording to get started writing UI tests.
    //        // Use XCTAssert and related functions to verify your tests produce the correct results.
    //        let isMapViewVisible = app.otherElements["mapView"].exists
    //        XCTAssertTrue(isMapViewVisible)
    //
    //        let leader = app.navigationBars.buttons["leaderBtn"]
    //        leader.tap()
    //        XCTAssertTrue(app.otherElements["Leaderboard"].exists)
    //
    //        app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()
    //
    //        let isTabBarVisible = app.tabBars.firstMatch.exists
    //        XCTAssertTrue(isTabBarVisible)
    //
    //        let profileTab = app.tabBars.firstMatch.buttons.element(boundBy: 1)
    //        profileTab.tap()
    //        XCTAssertTrue(app.otherElements["User Profile"].exists)
    //
    //        let homeTab = app.tabBars.firstMatch.buttons.element(boundBy: 0)
    //        homeTab.tap()
    //        XCTAssertTrue(app.otherElements["Home"].exists)
    //
    //        let settingsTab = app.tabBars.firstMatch.buttons.element(boundBy: 2)
    //        settingsTab.tap()
    //        XCTAssertTrue(app.otherElements["Settings"].exists)
    //
    //        let choose = app.tables["settingsTable"].cells.allElementsBoundByIndex[0]
    //        choose.tap()
    //        XCTAssertTrue(app.otherElements["Choose your interests"].exists)
    //
    //        app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()
    //
    //        let other = app.tables["settingsTable"].cells.allElementsBoundByIndex[1]
    //        other.tap()
    //        XCTAssertTrue(app.otherElements["More Settings"].exists)
    //
    //        app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()
    //
    //        let searchTab = app.tabBars.firstMatch.buttons.element(boundBy: 3)
    //        searchTab.tap()
    //        XCTAssertTrue(app.buttons["Places"].exists)
    //        XCTAssertTrue(app.buttons["People"].exists)
    //        XCTAssertTrue(app.buttons["Tags"].exists)
    //
    //        app.tabBars.firstMatch.buttons.element(boundBy: 0).tap()
    //        app.buttons["addFactButton"].tap()
    //        XCTAssertTrue(app.buttons["submit"].exists)
    //    }

}
