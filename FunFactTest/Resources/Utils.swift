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
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
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
    static func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: Any, type: AlertType) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel,handler: {_ in
            switch(type) {
            case .textfield:
                (toFocus as! UITextField).becomeFirstResponder()
            case .textview:
                (toFocus as! UITextView).becomeFirstResponder()
            case .imageview:
                (toFocus as! UIImageView).becomeFirstResponder()
            case .pickerview:
                (toFocus as! UIPickerView).becomeFirstResponder()
            default:
                print("default")
            }
            
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
    }
    static func compareColors (c1:UIColor, c2:UIColor) -> Bool{
        // some kind of weird rounding made the colors unequal so had to compare like this
        
        var red:CGFloat = 0
        var green:CGFloat  = 0
        var blue:CGFloat = 0
        var alpha:CGFloat  = 0
        c1.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        var red2:CGFloat = 0
        var green2:CGFloat  = 0
        var blue2:CGFloat = 0
        var alpha2:CGFloat  = 0
        c2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return (Int(green*255) == Int(green2*255))
        
    }
    static func showQuickHelp() -> UIAlertController{
        let quickHelpView = UIAlertController(title: "Help", message: "", preferredStyle: .actionSheet)
        let title = "How To Verify A Fact\n\n"
        let titleString = NSMutableAttributedString(
            string: title,
            attributes: [
                NSAttributedString.Key.font: UIFont(name: Fonts.boldFont, size: 16.0)!,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        let message = NSMutableAttributedString()
        message.normal("Thank you for helping us verify this fact! Given below are some tips on the verification process:\n")
        .bold("\nStep 1").normal(": Ensure that the image and the landmark name are accurate for the fact.\n")
        .bold("\nStep 2").normal(": Ensure that the source is a valid website.\n")
        .bold("\nStep 3").normal(": Read the fact and ensure that the text is taken from the source.\n")
        .bold("\nStep 4").normal("""
        : Use your judgment and ensure that the fact is not inflammatory/derogatory in any way.\n
        If all of the above hold true, please go ahead and click Approve, otherwise click Reject.\n
        Click on the Help icon above to view this again.
        """)
        let string = message.string
        
        message.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, string.count - 1))
        let finalMessage = NSMutableAttributedString()
        finalMessage.append(titleString)
        finalMessage.append(message)
        
        quickHelpView.setValue(finalMessage, forKey: "attributedMessage")
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            quickHelpView.dismiss(animated: true)
        }
        quickHelpView.addAction(dismissAction)
        return quickHelpView
    }
    static func showAlert(status: Status, message: String) -> UIAlertController {
        var popup = UIAlertController()
        switch status {
        case .success:
            popup = UIAlertController(title: "Success",
                                      message: message,
                                      preferredStyle: .alert)
        case .failure:
            popup = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        }
        return popup
    }
    static func showLoader(view: UIView) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        spinner.backgroundColor = UIColor.clear
        spinner.color = UIColor.black
        spinner.layer.cornerRadius = 3.0
        spinner.clipsToBounds = true
        spinner.hidesWhenStopped = true
        spinner.style = UIActivityIndicatorView.Style.gray
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        return spinner
    }
}
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: Fonts.boldFont, size: 14)!]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: Fonts.regularFont, size: 14)!]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        
        return self
    }
}
