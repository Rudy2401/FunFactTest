//
//  FunFactStruct.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/19/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct ListOfLandmarks  {
    var listOfLandmarks: [Landmark]
}
struct Landmark {
    var id: String
    var name: String
    var address: String
    var city: String
    var state: String
    var zipcode: String
    var country: String
    var type: String
    var coordinates: GeoPoint
    var image: String
}
