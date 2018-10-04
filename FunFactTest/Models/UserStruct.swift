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
    var listOfLandmarks: [User]
}
struct User {
    var uid: String
    var dislikeCount: Int
    var disputeCount: Int
    var likeCount: Int
    var submittedCount: Int
    var email: String
    var name: String
    var phoneNumber: String
    var photoURL: String
    var provider: String
    var funFactsDisputed: [DocumentReference]
    var funFactsLiked: [DocumentReference]
    var funFactsDisliked: [DocumentReference]
    var funFactsSubmitted: [DocumentReference]
}

struct FunFactsDisputed {
    var disputeID: DocumentReference
}

struct FunFactsLiked {
    var funFactID: DocumentReference
}

struct FunFactsDisliked {
    var funFactID: DocumentReference
}

struct FunFactsSubmitted {
    var funFactID: DocumentReference
}
