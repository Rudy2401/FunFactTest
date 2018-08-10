//
//  FunFactAnnotation.swift
//  GeoTargeting
//
//  Created by Rushi Dolas on 6/7/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import MapKit

class FunFactAnnotation: NSObject, MKAnnotation {
    let landmarkID: String
    let title: String?
    let address: String
    let type: String
    let coordinate: CLLocationCoordinate2D
    
    init(landmarkID: String, title: String, address: String, type: String, coordinate: CLLocationCoordinate2D) {
        self.landmarkID = landmarkID
        self.title = title
        self.address = address
        self.type = type
        self.coordinate = coordinate
        super.init()
    }
    
    var subtitle: String? {
        return address
    }
}
