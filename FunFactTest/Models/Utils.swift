//
//  Utils.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/21/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Utils {
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func addressToCoordinatesConverter(address: String) -> CLLocationCoordinate2D {
        print (address)
        let geoCoder = CLGeocoder()
        var coordinates = CLLocationCoordinate2D()
        geoCoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error!)
            }
            if let placemark = placemarks?[0] {
                coordinates = placemark.location!.coordinate
            }
            print (coordinates.latitude)
        })
        return coordinates
    }
    
    static func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: Any, type: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            switch(type) {
            case "textfield":
                (toFocus as! UITextField).becomeFirstResponder()
            case "textview":
                (toFocus as! UITextView).becomeFirstResponder()
            case "imageview":
                (toFocus as! UIImageView).becomeFirstResponder()
            case "pickerview":
                (toFocus as! UIPickerView).becomeFirstResponder()
            default:
                print("default")
            }
            
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
    }
}