//
//  DisputeStruct.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/29/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation

struct ListOfDisputes  {
    var listOfDisputes: [Dispute]
}

struct Dispute  {
    let disputeID: String
    let funFactID: String
    let reason: String
    let description: String
    let user: String
    let dateSubmitted: String
}
