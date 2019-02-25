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
    var disputeID: String
    var funFactID: String
    var reason: String
    var description: String
    var user: String
    var dateSubmitted: String
}
