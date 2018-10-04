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
    let landmarkId: String
    let id: String
    let description: String
    let likes: Int
    let dislikes: Int
    let verificationFlag: String
    let image: String
    let imageCaption: String
    let disputeFlag: String
    let submittedBy: String
    let dateSubmitted: String
    let source: String
    let tags: [String]
}
