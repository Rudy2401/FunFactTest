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

class DisputeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    @IBOutlet weak var helpText: UILabel!
    @IBOutlet weak var reasonPicker: UIPickerView!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    var pickerData: [String] = [String]()
    var funFactID: String = ""
    var disputeDict = [String: Dispute]()
    var reason = ""
    var popup = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        let db = Firestore.firestore()
        downloadDisputes(db)

        self.hideKeyboardWhenTappedAround() 
        pickerData = ["--- Select a reason ---", "Factually incorrect", "Fact belongs to another landmark", "Derogatory/Offensive text", "Other"]
        self.reasonPicker.delegate = self
        self.reasonPicker.dataSource = self
        self.notesText.delegate = self
        
        let cancelItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelAction(_:))
        )
        navigationItem.rightBarButtonItem = cancelItem
        
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
        
        submitButton.layer.backgroundColor = Constants.redColor.cgColor
        submitButton.layer.cornerRadius = 25
        print(funFactID)
    }
    
    func downloadDisputes(_ db: Firestore) {
        db.collection("disputes").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let dispute = Dispute(disputeID: document.data()["disputeID"] as! String,
                                          funFactID: document.data()["funFactID"] as! String,
                                          reason: document.data()["reason"] as! String,
                                          description: document.data()["description"] as! String,
                                          user: document.data()["user"] as! String,
                                          dateSubmitted: document.data()["dateSubmitted"] as! String)
                    self.disputeDict[self.funFactID] = dispute
                }
            }
        }
    }
    
    @objc func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitDispute(_ sender: Any) {
        if validatePage() {
            return
        }
        let db = Firestore.firestore()
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "MMM dd, yyyy"
        let myStringafd = formatter.string(from: yourDate!)
        let delimiter = "-"
        
        var count = 0
        for disputeID in self.disputeDict.keys {
            let dis = disputeID.components(separatedBy: delimiter)
            let fid = dis[0] + "-" + dis[1]
            if funFactID == fid {
                count += 1
            }
        }
        
        let did = funFactID + "-" + String(count+1)
        
        db.collection("disputes").document(did).setData([
            "disputeID": did,
            "funFactID": funFactID,
            "reason": reason,
            "description": notesText.text,
            "user": Auth.auth().currentUser?.uid ?? "",
            "dateSubmitted": myStringafd
        ]){ err in
            if let err = err {
                print("Error writing document: \(err)")
                self.showAlert(message: "fail")
            } else {
                print("Document successfully written!")
                self.showAlert(message: "success")
            }
        }
        let disputeRef = db.collection("funFacts").document(funFactID)
        
        // Set the "capital" field of the city 'DC'
        disputeRef.updateData([
            "disputeFlag": "Y"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
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
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            toFocus.becomeFirstResponder()
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
    }
    func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: UIPickerView) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
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
        let title = NSAttributedString(string: data, attributes: [NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
}
