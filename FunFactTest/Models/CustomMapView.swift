//
//  CustomMapView.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/25/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import MapKit

class CustomMapView: MKMapView {
    var funFactAnnotations: [FunFactAnnotation]?
    
    init(funFactAnnotations: [FunFactAnnotation]) {
        super.init()
        self.funFactAnnotations = funFactAnnotations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
