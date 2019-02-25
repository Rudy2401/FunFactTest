//
//  DisputeViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 7/23/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DisputeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, FirestoreManagerDelegate {
    
    @IBOutlet weak var helpText: UILabel!
    @IBOutlet weak var reasonPicker: UIPickerView!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var submitButton: CustomButton!
    var pickerData: [String] = [String]()
    var funFactID: String = ""
    var reason = ""
    var popup = UIAlertController()
    var firestore = FirestoreManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.darkGray

        pickerData = Constants.disputeReason
        self.reasonPicker.delegate = self
        self.reasonPicker.dataSource = self
        self.notesText.delegate = self
        
        reasonPicker.layer.borderWidth = 0
        reasonPicker.layer.borderColor = UIColor.gray.cgColor
        reasonPicker.layer.cornerRadius = 5
        
        let cancelItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelAction(_:))
        )
        navigationItem.rightBarButtonItem = cancelItem
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .darkGray
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            if #available(iOS 11.0, *) {
                navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: customFont ]
            } else {
                // Fallback on earlier versions
            }
        }
        navigationItem.title = "Dispute Fact"
        
        notesText.text = "Enter your comments"
        notesText.textColor = UIColor.lightGray
        reasonPicker.layer.cornerRadius = 5
        
        notesText.layer.borderWidth = 0
        notesText.layer.borderColor = UIColor.gray.cgColor
        notesText.layer.cornerRadius = 5
        
        submitButton.layer.backgroundColor = Colors.seagreenColor.cgColor
        print(funFactID)
    }
    func documentsDidUpdate() {
        
    }
    
    @objc func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitDispute(_ sender: Any) {
        if validatePage() {
            return
        }
        let db = Firestore.firestore()
        
        let date = Timestamp(date: Date())
        let did = db.collection("disputes").document().documentID
        firestore.addDispute(for: did,
                             funFactID: funFactID,
                             reason: reason,
                             description: notesText.text,
                             user: Auth.auth().currentUser?.uid ?? "",
                             date: date,
                             completion: { (status) in
                                self.showAlert(message: status)
                            })
        
        firestore.updateDisputeFlag(funFactID: funFactID)
        firestore.addUserDisputes(disputeID: did, userID: Auth.auth().currentUser?.uid ?? "")
    }
    
    func showAlert(message: String) {
        if message == "success" {
            popup = UIAlertController(title: "Success", message: "Dispute uploaded successfully!", preferredStyle: .alert)
        }
        if message == "fail" {
            popup = UIAlertController(title: "Error", message: "Error while uploading Dispute", preferredStyle: .alert)
        }
        
        self.present(popup, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }
    
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    func validatePage() -> Bool{
        var errors = false
        let title = "Error"
        var message = ""

        if notesText?.text == "Enter your comments" {
            errors = true
            message += "Please enter a valid description"
            alertWithTitle(title: title, message: message, viewController: self, toFocus: self.notesText!)
        }
        if reason.isEmpty || reason == "--- Select a reason ---" {
            errors = true
            message += "Please enter a valid reason"
            alertWithTitle(title: title, message: message, viewController: self, toFocus: self.reasonPicker!)
        }
        return errors

    }
    
    func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: UITextView) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel,handler: {_ in
            toFocus.becomeFirstResponder()
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
    }
    func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: UIPickerView) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel,handler: {_ in
            toFocus.becomeFirstResponder()
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        reason = pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel?
        if label == nil {
            label = UILabel()
        }
        
        let data = pickerData[row]
        let title = NSAttributedString(string: data, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
}
