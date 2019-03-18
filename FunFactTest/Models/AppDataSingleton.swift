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
    var userProfile = UserProfile(uid: "",
                           dislikeCount: 0,
                           disputeCount: 0,
                           likeCount: 0,
                           submittedCount: 0,
                           verifiedCount: 0,
                           rejectedCount: 0,
                           email: "",
                           name: "",
                           userName: "",
                           level: "",
                           photoURL: "",
                           provider: "",
                           city: "",
                           country: "",
                           funFactsDisputed: [],
                           funFactsLiked: [],
                           funFactsDisliked: [],
                           funFactsSubmitted: [],
                           funFactsVerified: [],
                           funFactsRejected: [])
    
    var listOfLandmarkIDs = [String]()
    var event = Events.firstLoad
}
