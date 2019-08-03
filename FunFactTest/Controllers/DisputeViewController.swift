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
        navigationItem.title = "Dispute Fact"
        
        notesText.text = "Enter your comments"
        notesText.textColor = UIColor.lightGray
        reasonPicker.layer.cornerRadius = 5
        
        notesText.layer.borderWidth = 0
        notesText.layer.borderColor = UIColor.gray.cgColor
        notesText.layer.cornerRadius = 5
        
        submitButton.layer.backgroundColor = Colors.seagreenColor.cgColor
        print(funFactID)
        
        let toolBarAttrImageClicked = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                        NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 30, style: .solid)]
        let backLabel1 = String.fontAwesomeIcon(name: .angleDown)
        let backAttr1 = NSAttributedString(string: backLabel1, attributes: Attributes.navBarImageLightAttribute)
        let backAttrClicked1 = NSAttributedString(string: backLabel1, attributes: toolBarAttrImageClicked)
        let completebackLabel = NSMutableAttributedString()
        completebackLabel.append(backAttr1)
        
        let completebackLabelClicked = NSMutableAttributedString()
        completebackLabelClicked.append(backAttrClicked1)
        
        let back = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        back.isUserInteractionEnabled = true
        back.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        back.setAttributedTitle(completebackLabel, for: .normal)
        back.setAttributedTitle(completebackLabelClicked, for: .highlighted)
        back.setAttributedTitle(completebackLabelClicked, for: .selected)
        back.titleLabel?.textAlignment = .center
        navigationItem.backBarButtonItem?.title = ""
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
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
        let alertController = UIAlertController(title: "Dispute",
                                                message: "Are you sure you want to dispute this fact?",
                                                preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            let db = Firestore.firestore()
            let date = Timestamp(date: Date())
            let did = db.collection("disputes").document().documentID
            self.firestore.addDispute(for: did,
                                      funFactID: self.funFactID,
                                      reason: self.reason,
                                      description: self.notesText.text,
                                      user: Auth.auth().currentUser?.uid ?? "",
                                      date: date,
                                      completion: { (error) in
                                        if let error = error {
                                            print ("Error adding dispute \(error)")
                                            let alert = Utils.showAlert(status: .failure, message: ErrorMessages.disputeError)
                                            self.present(alert, animated: true) {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                                    guard self?.presentedViewController == alert else { return }
                                                    self?.dismiss(animated: true, completion: nil)
                                                }
                                            }
                                        } else {
                                            let alert = Utils.showAlert(status: .success, message: ErrorMessages.disputeSuccess)
                                            self.present(alert, animated: true) {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                                    guard self?.presentedViewController == alert else { return }
                                                    self?.dismiss(animated: true, completion: nil)
                                                    self?.navigationController?.popToRootViewController(animated: true)
                                                }
                                            }
                                        }
            })
            
            self.firestore.updateDisputeFlag(funFactID: self.funFactID)
            self.firestore.addUserDisputes(funFactID: self.funFactID, userID: Auth.auth().currentUser?.uid ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
        let title = NSAttributedString(string: data, attributes: [NSAttributedString.Key.font: UIFont(name: Fonts.regularFont, size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
}
