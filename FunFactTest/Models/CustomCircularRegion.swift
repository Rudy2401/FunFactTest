//
//  CustomCircularRegion.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/31/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import MapKit

extension CLRegion {
    var landmarkID: String? {
        get {
            return objc_getAssociatedObject(self, "landmarkID") as? String
        }
        set {
            objc_setAssociatedObject(self, "landmarkID", newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
