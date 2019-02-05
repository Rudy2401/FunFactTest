//
//  AppDataSingleton.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 1/6/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import Foundation

class AppDataSingleton {
    static let appDataSharedInstance = AppDataSingleton()
    var userProfile = User(uid: "",
                           dislikeCount: 0,
                           disputeCount: 0,
                           likeCount: 0,
                           submittedCount: 0,
                           email: "", name: "",
                           photoURL: "",
                           provider: "",
                           funFactsDisputed: [],
                           funFactsLiked: [],
                           funFactsDisliked: [],
                           funFactsSubmitted: [])
    var listOfLandmarks = ListOfLandmarks(listOfLandmarks: [])
    var listOfFunFacts = ListOfFunFacts(listOfFunFacts: [])
    var usersDict = [String: User]()
}
