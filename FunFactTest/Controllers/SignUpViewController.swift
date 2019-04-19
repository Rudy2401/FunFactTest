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
import IQKeyboardManagerSwift

class SignUpViewController: UIViewController, FirestoreManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: CustomButton!
    @IBOutlet weak var nameImageButton: UIButton!
    @IBOutlet weak var emailImageButton: UIButton!
    @IBOutlet weak var passwordImageButton: UIButton!
    var popup = UIAlertController()
    var firestore = FirestoreManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore.delegate = self
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        view.addBackground()
        emailTextField.keyboardType = .emailAddress
        navigationController?.navigationBar.isHidden = false
        nameImageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        nameImageButton.setTitle(String.fontAwesomeIcon(name: .idCard), for: .normal)
        emailImageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        emailImageButton.setTitle(String.fontAwesomeIcon(name: .envelope), for: .normal)
        passwordImageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        passwordImageButton.setTitle(String.fontAwesomeIcon(name: .lock), for: .normal)
        signUpButton.layer.backgroundColor = Colors.seagreenColor.cgColor
        let cancelItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelAction(_:))
        )
        navigationItem.rightBarButtonItem = cancelItem
        nameTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        emailTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Sign Up"
        navigationController?.isNavigationBarHidden = false
        nameTextField.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
        self.title = ""
    }
    func documentsDidUpdate() {
        
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
                let alertController = UIAlertController(title: "Registration Error",
                                                        message: error.localizedDescription,
                                                        preferredStyle: .alert)
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
                        let alert = Utils.showAlert(status: .failure, message: "Error while creating user.")
                        self.present(alert, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                guard self?.presentedViewController == alert else { return }
                                self?.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else {
                        self.firestore.updateUserAdditionalFields(for: Auth.auth().currentUser!, completion: { (error) in
                            if error != nil {
                                let alert = Utils.showAlert(status: .failure, message: "Error while creating user.")
                                self.present(alert, animated: true) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                        guard self?.presentedViewController == alert else { return }
                                        self?.dismiss(animated: true, completion: nil)
                                    }
                                }
                            } else {
                                let alert = Utils.showAlert(status: .success, message: "User created successfully!")
                                self.present(alert, animated: true) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                        guard self?.presentedViewController == alert else { return }
                                        self?.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        })
                    }
                })
            }
            // Dismiss keyboard
            self.view.endEditing(true)
            // Send verification email
            Auth.auth().currentUser?.sendEmailVerification(completion: nil)
            
            let alertController = UIAlertController(title: "Email Verification",
                                                    message: "We've just sent a confirmation email to your email address. Please check your inbox and click the verification link in that email to complete the sign up.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                // Dismiss the current view controller
                self.navigationController?.popViewController(animated: true)
                return
            })
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    @objc func doneButtonClicked(_ sender: Any) {
//        print (view.bounds)
//        UIView.animate(withDuration: 0.5, animations: {
//            self.view.transform = CGAffineTransform(translationX: 0,
//                                                    y: 80)
//        }, completion: nil)
    }
}
