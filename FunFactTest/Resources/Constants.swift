//
//  Constants.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/23/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let blueColor = UIColor(displayP3Red: 0, green: 122/255, blue: 1.0, alpha: 1.0)
    static let redColor = UIColor(displayP3Red: 217/255, green: 84/255, blue: 61/255, alpha: 1.0)
    static let fbBlueColor = UIColor(displayP3Red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
    static let greenColor = UIColor(displayP3Red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    
    static let attribute12RegDG = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                                    NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 12.0)!]
    static let attribute12BoldDG = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                                     NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 12.0)!]
    static let attribute10RegDG = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                                    NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 10.0)!]
    static let attribute14ItalicsDG = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                                        NSAttributedStringKey.font: UIFont(name: "Avenir-BookOblique", size: 14.0)!]
    static let attribute14DemiBlack = [ NSAttributedStringKey.foregroundColor: UIColor.black,
                                        NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
    static let attribute14DemiBlue = [ NSAttributedStringKey.foregroundColor: blueColor,
                                        NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
    
    static let smallImageAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                       NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 12, style: .solid)]
    
    static let toolBarImageSolidAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                              NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 25, style: .solid)]
    
    static let toolBarLabelAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                         NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 10.0)!]
    
    static let toolBarImageClickedAttribute = [ NSAttributedStringKey.foregroundColor: Constants.redColor,
                                                NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 30, style: .solid)]
    static let toolBarLabelClickedAttribute = [ NSAttributedStringKey.foregroundColor: Constants.redColor,
                                                NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 10.0)!]
    
    static let loginButtonAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.white,
                                        NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let loginButtonImageBrandAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.white,
                                                  NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 20, style: .brands)]
    static let loginButtonImageSolidAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.white,
                                                  NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 20, style: .solid)]
    
    static let loginButtonClickedAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                               NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let loginButtonImageSolidClickedAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                                         NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 20, style: .solid)]
    static let loginButtonImageBrandClickedAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                                         NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 20, style: .brands)]
    
    static let googleLoginButtonAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                                              NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let googleLoginButtonImageSolidAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.white,
                                                        NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 20, style: .brands)]
    
    static let googleLoginButtonClickedAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                                     NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let googleLoginButtonImageSolidClickedAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                                               NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 20, style: .brands)]
    
    static let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    static let landmarkTypes = ["--- Select landmark type ---", "Apartment", "Office Building", "Stadium", "Museum", "Park", "Restaurant/Cafe", "Landmark"]
    
    static func getColorFor(type: String) -> UIColor {
        var color = UIColor()
        switch type {
        case Constants.landmarkTypes[1]:
            color = .orange
        case Constants.landmarkTypes[2]:
            color = .blue
        case Constants.landmarkTypes[3]:
            color = .black
        case Constants.landmarkTypes[4]:
            color = .green
        case Constants.landmarkTypes[5]:
            color = .cyan
        case Constants.landmarkTypes[6]:
            color = .gray
        case Constants.landmarkTypes[7]:
            color = .purple
        default:
            color = .red
        }
        return color
    }
}
