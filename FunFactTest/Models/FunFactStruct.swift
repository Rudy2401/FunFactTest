//
//  FunFactStruct.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/19/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct ListOfFunFacts  {
    var listOfFunFacts: Set<FunFact>
}

struct FunFact: Hashable  {
    var landmarkId: String
    var landmarkName: String
    var id: String
    var description: String
    var likes: Int
    var dislikes: Int
    var verificationFlag: String
    var image: String
    var imageCaption: String
    var disputeFlag: String
    var submittedBy: String
    var dateSubmitted: Timestamp
    var source: String
    var tags: [String]
    var approvalCount: Int
    var rejectionCount: Int
    var approvalUsers: [String]
    var rejectionUsers: [String]
    var rejectionReason: [String]
}
