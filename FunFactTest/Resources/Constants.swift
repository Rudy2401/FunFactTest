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
    
    static let attribute12RegDG = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                    NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 12.0)!]
    static let attribute12BoldDG = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                     NSAttributedString.Key.font: UIFont(name: "AvenirNext-Bold", size: 12.0)!]
    static let attribute10RegDG = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                    NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
    static let attribute14ItalicsDG = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                        NSAttributedString.Key.font: UIFont(name: "Avenir-BookOblique", size: 14.0)!]
    static let attribute14DemiBlack = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                                        NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
    static let attribute14DemiBlue = [ NSAttributedString.Key.foregroundColor: blueColor,
                                        NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
    
    static let smallImageAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                       NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 12, style: .solid)]
    
    static let toolBarImageSolidAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                              NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .solid)]
    
    static let toolBarLabelAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                         NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
    
    static let toolBarImageClickedAttribute = [ NSAttributedString.Key.foregroundColor: Constants.redColor,
                                                NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 30, style: .solid)]
    static let toolBarLabelClickedAttribute = [ NSAttributedString.Key.foregroundColor: Constants.redColor,
                                                NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
    
    static let loginButtonAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                        NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let loginButtonImageBrandAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                                  NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .brands)]
    static let loginButtonImageSolidAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                                  NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .solid)]
    
    static let loginButtonClickedAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                               NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let loginButtonImageSolidClickedAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                                         NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .solid)]
    static let loginButtonImageBrandClickedAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                                         NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .brands)]
    
    static let googleLoginButtonAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                              NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let googleLoginButtonImageSolidAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                                        NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .brands)]
    
    static let googleLoginButtonClickedAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                                     NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let googleLoginButtonImageSolidClickedAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                                               NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .brands)]
    
    static let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    
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
