//
//  FunFactStruct.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/19/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation

struct ListOfFunFacts  {
    var listOfFunFacts: [FunFact]
}

struct FunFact  {
    var landmarkId: String
    var id: String
    var description: String
    var likes: Int
    var dislikes: Int
    var verificationFlag: String
    var image: String
    var imageCaption: String
    var disputeFlag: String
    var submittedBy: String
    var dateSubmitted: String
    var source: String
    var tags: [String]
}
