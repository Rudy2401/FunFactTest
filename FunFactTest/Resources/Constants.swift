//
//  Constants.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/23/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit

enum Colors {
    static let blueColor = UIColor(displayP3Red: 0, green: 122/255, blue: 1.0, alpha: 1.0)
    static let seagreenColor = UIColor(displayP3Red: 46/255, green: 139/255, blue: 87/255, alpha: 1.0)
    static let fbBlueColor = UIColor(displayP3Red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
    static let greenColor = UIColor(displayP3Red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    static let redColor = UIColor(displayP3Red: 178/255, green: 34/255, blue: 34/255, alpha: 1.0)
}

enum Attributes {
    static let attribute12RegDG = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                    NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 12.0)!]
    static let attribute12BoldDG = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                     NSAttributedString.Key.font: UIFont(name: "AvenirNext-Bold", size: 12.0)!]
    static let attribute12BoldBlue = [ NSAttributedString.Key.foregroundColor: Colors.blueColor,
                                       NSAttributedString.Key.font: UIFont(name: "AvenirNext-Bold", size: 12.0)!]
    static let attribute12RegBlue = [ NSAttributedString.Key.foregroundColor: Colors.blueColor,
                                       NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 12.0)!]
    static let attribute10RegDG = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                    NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
    static let attribute14ItalicsDG = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                        NSAttributedString.Key.font: UIFont(name: "Avenir-BookOblique", size: 14.0)!]
    static let attribute14DemiBlack = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                                        NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
    static let attribute16DemiBlack = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                                        NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 16.0)!]
    static let attribute14DemiBlue = [ NSAttributedString.Key.foregroundColor: Colors.blueColor,
                                       NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
    
    static let smallImageAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                       NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 12, style: .solid)]
    
    static let toolBarImageSolidAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                              NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .solid)]
    
    static let navBarImageSolidAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                             NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .light)]
    
    static let addFactButtonAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                          NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .light)]
    
    static let toolBarLabelAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                         NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
    
    static let toolBarImageClickedAttribute = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
                                                NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 30, style: .solid)]
    static let toolBarLabelClickedAttribute = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
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
    
    static let searchButtonAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.1, alpha: 1.0),
                                        NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 14.0)!]
    static let searchButtonSelectedAttribute = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
                                         NSAttributedString.Key.font: UIFont(name: "AvenirNext-Bold", size: 14.0)!]

}

struct AnnotationType {
    var color: UIColor
    var image: UIImage
}

struct Constants {
    static let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                               target: nil,
                                               action: nil)
    
    static let landmarkTypes = ["--- Select landmark type ---",
                                "Apartment",
                                "Office Building",
                                "Stadium",
                                "Museum",
                                "Park",
                                "Restaurant/Cafe",
                                "Landmark"]
    
    static func getMarkerDetails(type: String) -> AnnotationType {
        var annotationType = AnnotationType(color: UIColor(), image: UIImage())
        switch type {
        case Constants.landmarkTypes[1]:
            annotationType.color = .orange
            annotationType.image = UIImage.fontAwesomeIcon(name: .home, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
        case Constants.landmarkTypes[2]:
            annotationType.color = .blue
            annotationType.image = UIImage.fontAwesomeIcon(name: .building, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
        case Constants.landmarkTypes[3]:
            annotationType.color = .black
            annotationType.image = UIImage.fontAwesomeIcon(name: .footballBall, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
        case Constants.landmarkTypes[4]:
            annotationType.color = .green
            annotationType.image = UIImage.fontAwesomeIcon(name: .book, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
        case Constants.landmarkTypes[5]:
            annotationType.color = .cyan
            annotationType.image = UIImage.fontAwesomeIcon(name: .tree, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
        case Constants.landmarkTypes[6]:
            annotationType.color = .gray
            annotationType.image = UIImage.fontAwesomeIcon(name: .utensils, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
        case Constants.landmarkTypes[7]:
            annotationType.color = .purple
            annotationType.image = UIImage.fontAwesomeIcon(name: .university, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
        default:
            annotationType.color = .red
        }
        return annotationType
    }
}
