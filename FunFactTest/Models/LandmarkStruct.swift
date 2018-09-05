//
//  FunFactStruct.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/19/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation

struct ListOfLandmarks  {
    var listOfLandmarks: [Landmark]
}
struct Landmark {
    let id: String
    let name: String
    let address: String
    let city: String
    let state: String
    let zipcode: String
    let country: String
    let type: String
    let latitude: String
    let longitude: String
    let image: String
}
