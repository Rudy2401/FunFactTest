//
//  AddressDataStruct.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/21/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import Foundation
import CoreLocation

struct AddressData {
    var address: String?
    var landmarkName: String?
    var coordinate: CLLocationCoordinate2D?
    var city: String?
    var state: String?
    var country: String?
    var zipcode: String?
}
