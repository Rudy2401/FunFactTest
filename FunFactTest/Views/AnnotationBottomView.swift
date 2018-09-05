//
//  AnnotationBottomView.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/20/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit

class AnnotationBottomView: UIView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.backgroundColor = UIColor.white

    }
//    override func draw(_ rect: CGRect) {
//        updateLayerProperties()
//    }
//    
//    func updateLayerProperties() {
//        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 3)
//        self.layer.shadowOpacity = 1.0
//        self.layer.shadowRadius = 10.0
//        self.layer.masksToBounds = false
//
//        self.backgroundColor = UIColor.white
//        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        self.layer.borderWidth = CGFloat.init(0.2)
//        self.layer.borderColor = UIColor.lightGray.cgColor
//        self.layer.cornerRadius = 5
//    }
}
