//
//  CustomButton.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 9/6/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        // Common logic goes here
        refreshCorners(value: cornerRadius)
        setFont(font: Fonts.regularFont, size: 17.0)
    }
    
    func setFont(font: String, size: Double) {
        self.titleLabel?.font = UIFont(name: font, size: CGFloat(size))
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
    
    @IBInspectable var cornerRadius: CGFloat = 25 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
}
