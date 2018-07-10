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
    let title: String?
    let address: String
    let type: String
    let coordinate: CLLocationCoordinate2D
    let image: UIImage
    let imageView: UIImageView
    let pinColor: UIColor!
    
    init(title: String, address: String, type: String, coordinate: CLLocationCoordinate2D, image: UIImage, pinColor: UIColor) {
        self.title = title
        self.address = address
        self.type = type
        self.coordinate = coordinate
        self.image = image
        self.imageView = UIImageView(image: image)
        self.pinColor = pinColor
        super.init()
    }
    
    var subtitle: String? {
        return address
    }
}
