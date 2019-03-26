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
    static let maroonColor = UIColor(displayP3Red: 176/255, green: 48/255, blue: 96/255, alpha: 1.0)
    static let airforceBlueColor = UIColor(displayP3Red: 93/255, green: 138/255, blue: 168/255, alpha: 1.0)
    static let azureBlue = UIColor(displayP3Red: 0/255, green: 128/255, blue: 255/255, alpha: 1.0)
}

enum UserRole {
    static let editor = "Editor"
    static let general = "General"
    static let admin = "Admin"
}

enum UserLevel {
    static let rookie = "Rookie"
    static let advanced = "Advanced"
    static let superstar = "Super Star"
    static let creme = "Crème de la crème"
}

enum ImageType {
    static let profile = "profileImages"
    static let funFact = "images"
}
enum ProfileMode {
    case currentUser
    case otherUser
}

enum ListOfFunFactsByType {
    case submissions
    case disputes
    case verifications
    case rejections
    case hashtags
    case landmarks
}

enum LandmarkTypes {
    static let landmark = "Landmark"
    static let art = "Art & Culture"
    static let restaurant = "Restaurants, Bars & Cafes"
    static let cool = "Cool & Unique"
    static let park = "Parks & Gardens"
    static let natural = "Natural Landmarks"
    static let historic = "Historic Places"
    static let promotions = "Promotions"
}

enum Events {
    case firstLoad
    case mapEvent
    case notification
}

enum FirestoreErrors {
    static let annotationExists = "Annotation already present"
    static let mapTooLarge = "Map area too large"
}

enum Errors: Error {
    case noRecordsFound
}

enum Status {
    case success
    case failure
}

enum ErrorMessages {
    static let funFactUploadError = "Error while uploading fun fact"
    static let funFactUploadSuccess = "Fun fact uploaded succesfully!"
    static let verificationError = "Error while verifying."
    static let disputeError = "Error uploading dispute."
    static let disputeSuccess = "Dispute uploaded successfully!"
    static let updateUserError = "Error while updating user profile."
    static let updateUserSuccess = "User profile updated successfully!"
    static let noRecordsFound = "No records found, zoom out to view more"
    static let userCreateError = "Error while creating user."
    static let userCreateSuccess = "User created successfully!"
    static let rejectionSuccess = "Uploaded successfully!"
    static let rejectionError = "Error while uploading."
    static let interestsSuccess = "User interests updated successfully!"
}

enum Mode {
    case edit
    case add
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
    static let attribute14Gray = [ NSAttributedString.Key.foregroundColor: UIColor.gray,
                                        NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
    static let attribute16Gray = [ NSAttributedString.Key.foregroundColor: UIColor.gray,
                                   NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 16.0)!]
    static let attribute12Gray = [ NSAttributedString.Key.foregroundColor: UIColor.gray,
                                   NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 12.0)!]
    static let attribute16DemiBlack = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                                        NSAttributedString.Key.font: UIFont(name: "Charter-Bold", size: 16.0)!]
    static let attribute16DemiBlackAve = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                                        NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 16.0)!]
    static let attribute14DemiBlue = [ NSAttributedString.Key.foregroundColor: Colors.blueColor,
                                       NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
    static let attribute16DemiBlue = [ NSAttributedString.Key.foregroundColor: Colors.blueColor,
                                       NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 16.0)!]
    
    static let smallImageAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                       NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 12, style: .solid)]
    
    static let toolBarImageSolidAttribute = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                              NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .solid)]
    
    static let navBarImageLightAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                             NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .light)]
    
    static let addFactButtonAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                          NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .light)]
    static let currentLocationButtonAttribute = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
                                          NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .solid)]
    
    static let toolBarLabelAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                         NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
    
    static let toolBarImageClickedAttribute = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
                                                NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 30, style: .solid)]
    static let toolBarLabelClickedAttribute = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
                                                NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
    
    static let loginButtonAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                        NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let cancelButtonAttribute = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
                                        NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 16.0)!]
    static let cancelButtonClickedAttribute = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
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
                                LandmarkTypes.art,
                                LandmarkTypes.cool,
                                LandmarkTypes.historic,
                                LandmarkTypes.landmark,
                                LandmarkTypes.natural,
                                LandmarkTypes.park,
                                LandmarkTypes.restaurant]
    
    static let rejectionReason = ["Source invalid",
                                  "Fact does not match the source",
                                  "Image incorrect",
                                  "Inflammatory/Derogatory content",
                                  "Landmark Name does not match the fact",
                                  "Fact has too many grammatical errors/spelling mistakes",
                                  "Other"]
    
    static let disputeReason = ["--- Select a reason ---",
                                "Factually incorrect",
                                "Fact belongs to another landmark",
                                "Inflammatory/Derogatory content",
                                "Source website content is inaccurate",
                                "Other"]
    
    static func getMarkerDetails(type: String, width: Double, height: Double) -> AnnotationType {
        var annotationType = AnnotationType(color: UIColor(), image: UIImage())
        switch type {
        case LandmarkTypes.art:
            annotationType.color = .orange
            annotationType.image = UIImage.fontAwesomeIcon(name: .theaterMasks, style: .solid, textColor: .white, size: CGSize(width: width, height: height))
        case LandmarkTypes.cool:
            annotationType.color = .purple
            annotationType.image = UIImage.fontAwesomeIcon(name: .alicorn, style: .solidp, textColor: .white, size: CGSize(width: width, height: height))
        case LandmarkTypes.historic:
            annotationType.color = Colors.maroonColor
            annotationType.image = UIImage.fontAwesomeIcon(name: .monument, style: .solid, textColor: .white, size: CGSize(width: width, height: height))
        case LandmarkTypes.landmark:
            annotationType.color = Colors.airforceBlueColor
            annotationType.image = UIImage.fontAwesomeIcon(name: .landmark, style: .solid, textColor: .white, size: CGSize(width: width, height: height))
        case LandmarkTypes.natural:
            annotationType.color = Colors.azureBlue
            annotationType.image = UIImage.fontAwesomeIcon(name: .water, style: .solid, textColor: .white, size: CGSize(width: width, height: height))
        case LandmarkTypes.park:
            annotationType.color = Colors.seagreenColor
            annotationType.image = UIImage.fontAwesomeIcon(name: .trees, style: .solidp, textColor: .white, size: CGSize(width: width, height: height))
        case LandmarkTypes.promotions:
            annotationType.color = .yellow
            annotationType.image = UIImage.fontAwesomeIcon(name: .star, style: .solid, textColor: .white, size: CGSize(width: width, height: height))
        case LandmarkTypes.restaurant:
            annotationType.color = .darkGray
            annotationType.image = UIImage.fontAwesomeIcon(name: .utensils, style: .solid, textColor: .white, size: CGSize(width: width, height: height))
        default:
            annotationType.color = .red
        }
        return annotationType
    }
}
