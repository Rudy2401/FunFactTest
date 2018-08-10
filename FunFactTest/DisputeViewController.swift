//
//  DisputeViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 7/23/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit

class DisputeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    @IBOutlet weak var helpText: UILabel!
    @IBOutlet weak var reasonPicker: UIPickerView!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    var pickerData: [String] = [String]()
    var funFactID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        pickerData = ["--- Select a reason ---", "Factually incorrect", "Fact belongs to another landmark", "Derogatory/Offensive text", "Other"]
        self.reasonPicker.delegate = self
        self.reasonPicker.dataSource = self
        self.notesText.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .darkGray
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: customFont ]
        }
        navigationItem.title = "Dispute Fact"
        
        notesText.text = "Enter your comments"
        notesText.textColor = UIColor.lightGray
        reasonPicker.layer.cornerRadius = 5
        
        notesText.layer.borderWidth = CGFloat.init(0.5)
        notesText.layer.borderColor = UIColor.gray.cgColor
        notesText.layer.cornerRadius = 5
        
        submitButton.layer.backgroundColor = UIColor(displayP3Red: 0/255, green: 122/255, blue: 1.0, alpha: 1.0).cgColor
        submitButton.layer.cornerRadius = 15
        print(funFactID)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your comments"
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel?
        if label == nil {
            label = UILabel()
        }
        
        let data = pickerData[row]
        let title = NSAttributedString(string: data, attributes: [NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
