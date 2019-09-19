//
//  UserStruct.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 9/30/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct ListOfUsers  {
    var listOfLandmarks: [UserProfile]
}
struct UserProfile {
    var uid: String
    var dislikeCount: Int
    var disputeCount: Int
    var likeCount: Int
    var submittedCount: Int
    var verifiedCount: Int
    var rejectedCount: Int
    var email: String
    var name: String
    var userName: String
    var level: String
    var photoURL: String
    var provider: String
    var city: String
    var country: String
    var roles: [String]
    var funFactsDisputed: [FunFactMini]
    var funFactsLiked: [FunFactMini]
    var funFactsDisliked: [FunFactMini]
    var funFactsSubmitted: [FunFactMini]
    var funFactsVerified: [FunFactMini]
    var funFactsRejected: [FunFactMini]
}

struct Leader {
    var userID: String
    var count: Int
    var location: String
    var photoURL: String
}
