//
//  SignUpViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/27/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: CustomButton!
    @IBOutlet weak var nameImageButton: UIButton!
    @IBOutlet weak var emailImageButton: UIButton!
    @IBOutlet weak var passwordImageButton: UIButton!
    var popup = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addBackground()
        navigationController?.navigationBar.isHidden = false

        navigationController?.navigationBar.tintColor = UIColor.darkGray
        nameImageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        nameImageButton.setTitle(String.fontAwesomeIcon(name: .idCard), for: .normal)
        
        emailImageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        emailImageButton.setTitle(String.fontAwesomeIcon(name: .envelope), for: .normal)
        
        passwordImageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        passwordImageButton.setTitle(String.fontAwesomeIcon(name: .lock), for: .normal)
        
        signUpButton.layer.backgroundColor = Constants.redColor.cgColor
        
        let cancelItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelAction(_:))
        )
        navigationItem.rightBarButtonItem = cancelItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Sign Up"
        nameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerAccount(sender: UIButton) {
        
        // Validate the input
        guard let name = nameTextField.text, name != "",
            let emailAddress = emailTextField.text, emailAddress != "",
            let password = passwordTextField.text, password != "" else {
                
                let alertController = UIAlertController(title: "Registration Error", message: "Please make sure you provide your name, email address and password to complete the registration.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        // Register the user account on Firebase
        Auth.auth().createUser(withEmail: emailAddress, password: password, completion: { (user, error) in
            
            if let error = error {
                let code = (error as NSError).code
                print(code)
                let alertController = UIAlertController(title: "Registration Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Save the name of the user
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = name
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print("Failed to change the display name: \(error.localizedDescription)")
                    }
                })
            }
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            // Send verification email
            Auth.auth().currentUser?.sendEmailVerification(completion: nil)
            let db = Firestore.firestore()
            db.collection("users").document((Auth.auth().currentUser?.uid)!).setData([
                "uid": Auth.auth().currentUser?.uid ?? "",
                "email": Auth.auth().currentUser?.email ?? "",
                "name": name,
                "provider": Auth.auth().currentUser?.providerData[0].providerID ?? "",
                "photoURL": Auth.auth().currentUser?.photoURL?.absoluteString ?? "",
                "phoneNumber": Auth.auth().currentUser?.phoneNumber ?? "",
                "disputeCount": 0,
                "submittedCount": 0,
                "likeCount": 0,
                "dislikeCount": 0
            ]){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showAlert(message: "success")
                } else {
                    print("Document successfully written!")
                    self.showAlert(message: "fail")
                }
            }
            
            let alertController = UIAlertController(title: "Email Verification", message: "We've just sent a confirmation email to your email address. Please check your inbox and click the verification link in that email to complete the sign up.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                // Dismiss the current view controller
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            
        })
        
    }
    func showAlert(message: String) {
        if message == "success" {
            popup = UIAlertController(title: "Success", message: "User created successfully!", preferredStyle: .alert)
        }
        if message == "fail" {
            popup = UIAlertController(title: "Error", message: "Error while creating user", preferredStyle: .alert)
        }
        
        self.present(popup, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }

}
