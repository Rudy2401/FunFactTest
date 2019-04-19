//
//  AddFactTextViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/25/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

extension AddNewFactViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        funFactDescription.toolbarPlaceholder = "\(300 - textView.text.count) chars remaining"
        if textView.text.count > 300 {
            let selectedRange = textView.selectedRange
            let str1 = textView.text.substring(toIndex: 300)
            let str2 = textView.text.substring(fromIndex: 300)
            
            let strAttr1 = NSMutableAttributedString(string: str1, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                                NSAttributedString.Key.font: UIFont(name: Fonts.regularFont, size: 14.0)! ])
            let strAttr2 = NSMutableAttributedString(string: str2, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red,
                                                                                NSAttributedString.Key.font: UIFont(name: Fonts.regularFont, size: 14.0)! ])
            
            let str = NSMutableAttributedString()
            str.append(strAttr1)
            str.append(strAttr2)
            textView.attributedText = str
            textView.selectedRange = selectedRange
        } else {
            textView.textColor = .black
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        tag = textView.tag
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            funFactDescription.toolbarPlaceholder = "\(300 - textView.text.count) chars remaining"
            textView.textColor = UIColor.black
        }
        navigationController?.navigationBar.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView.tag == 0 {
                textView.text = "Click on the icon to select image. Enter image caption here."
            } else if textView.tag == 1 {
                textView.text = "Enter the fun fact details. Maximum 300 characters. Please keep the facts relevant and precise. Make sure to enter #hashtags to make your facts searchable."
            }
            textView.textColor = UIColor.lightGray
        }
        
        navigationController?.navigationBar.isHidden = false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationController?.navigationBar.isHidden = true
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationController?.navigationBar.isHidden = false
    }
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        autocompleteTableView.isHidden = true
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let tags = newText.components(separatedBy: "#")
        var tagSubstring = ""
        if tags.count > 1 && !((tags.last?.contains(" "))! || (tags.last?.contains("."))!) {
            tagSubstring = tags.last!
            autocompleteTableView.isHidden = false	
            searchAutocompleteEntriesWithSubstring(substring: tagSubstring)
        }
        return true
    }
}
extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.endIndex.utf16Offset(in: self))) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.endIndex.utf16Offset(in: self)
        } else {
            return false
        }
    }
}
