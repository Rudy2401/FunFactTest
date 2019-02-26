//
//  AddFactTextViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/25/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit

extension AddNewFactViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        tag = textView.tag
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
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
        let numberOfChars = newText.count
        let tags = newText.components(separatedBy: "#")
        var tagSubstring = ""
        if tags.count > 1 && !((tags.last?.contains(" "))! || (tags.last?.contains("."))!) {
            tagSubstring = tags.last!
            autocompleteTableView.isHidden = false
            searchAutocompleteEntriesWithSubstring(substring: tagSubstring)
        }
        return numberOfChars < 300
    }
}
