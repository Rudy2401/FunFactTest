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
        switch textView.tag {
        case Tags.caption.rawValue:
            UserDefaults.standard.set(textView.text, forKey: "caption")
        case Tags.description.rawValue:
            UserDefaults.standard.set(textView.text, forKey: "description")
        default:
            print ("Not textview")
        }
        if textView.text.isEmpty {
            if textView.tag == Tags.caption.rawValue {
                textView.text = imageCaptionPlaceholder
            } else if textView.tag == Tags.description.rawValue {
                textView.text = funFactDescPlaceholder
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
        switch textField.tag {
        case Tags.title.rawValue:
            UserDefaults.standard.set(textField.text, forKey: "title")
        case Tags.tags.rawValue:
            UserDefaults.standard.set(textField.text, forKey: "tags")
        case Tags.source.rawValue:
            UserDefaults.standard.set(textField.text, forKey: "source")
        default:
            print ("Not textfield")
        }
        
        navigationController?.navigationBar.isHidden = false
        if textField.tag == Tags.tags.rawValue {
            let changedText = textField.text?
                .components(separatedBy: " ")
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            let textComponents = changedText?.components(separatedBy: " ") ?? []
            var newText = [String]()
            for text in textComponents {
                if text.first != "#" {
                    newText.append("#\(text)")
                } else {
                    newText.append(text)
                }
            }
            let newText2 = newText.joined(separator: " ")
                .components(separatedBy: "#")
                .filter { !$0.isEmpty }
                .joined(separator: "#")
            
            let textComponents2 = newText2.replacingOccurrences(of: " ", with: "").components(separatedBy: "#")
            let newText3 = (textComponents2.count == 1 && textComponents2[0].isEmpty) ? "" : "#" + textComponents2.joined(separator: " #")
            textField.text = newText3
        }
    }
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString)
            .replacingCharacters(in: range, with: string)
        
        if textField.tag == Tags.tags.rawValue {
            autocompleteTableView.isHidden = true
            do {
                let regex = try NSRegularExpression(pattern: ".*[^#A-Za-z ].*", options: [])
                if regex.firstMatch(in: newText, options: [], range: NSMakeRange(0, newText.count)) != nil {
                    let alert = Utils.showAlert(status: .failure, message: "Only alphabets and # allowed")
                    self.present(alert, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                            guard self?.presentedViewController == alert else { return }
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            catch {
                print ("Caught regex error")
            }
            
            let tags = newText.components(separatedBy: " ")
            let tagSubstring = tags.last!
            autocompleteTableView.isHidden = false
            searchAutocompleteEntriesWithSubstring(substring: tagSubstring)
            if tagSubstring.last == " " || tagSubstring.count == 0 {
                autocompleteTableView.isHidden = true
            }
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
