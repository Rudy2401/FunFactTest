//
//  SignInViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/27/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: CustomButton!
    @IBOutlet weak var emailImageButton: UIButton!
    @IBOutlet weak var passwordImageButton: UIButton!
    @IBOutlet weak var signUpButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addBackground()
        navigationController?.navigationBar.isHidden = false

        navigationController?.navigationBar.tintColor = UIColor.darkGray
        emailImageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        emailImageButton.setTitle(String.fontAwesomeIcon(name: .envelope), for: .normal)
        
        passwordImageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        passwordImageButton.setTitle(String.fontAwesomeIcon(name: .lock), for: .normal)
        
        signInButton.layer.backgroundColor = Colors.seagreenColor.cgColor
        signUpButton.layer.backgroundColor = UIColor.darkGray.cgColor
        
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
        
        self.title = "Log In"
        emailTextField.becomeFirstResponder()
    }
    @objc func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func login(sender: UIButton) {
        
        // Validate the input
        guard let emailAddress = emailTextField.text, emailAddress != "",
            let password = passwordTextField.text, password != "" else {
                
                let alertController = UIAlertController(title: "Login Error", message: "Both fields must not be blank.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        // Perform login by calling Firebase APIs
        Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (user, error) in
            
            if let error = error {
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
                
            }
            
            // Email verification
            guard (Auth.auth().currentUser?.isEmailVerified)!
                else {
                    let alertController = UIAlertController(title: "Login Error", message: "You haven't confirmed your email address yet. We sent you a confirmation email when you signed up. Please click the verification link in that email. If you need us to send the confirmation email again, please tap Resend Email.", preferredStyle: .alert)
                    
                    let okayAction = UIAlertAction(title: "Resend email", style: .default, handler: { (action) in
                        Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
            }
            let db = Firestore.firestore()
            db.collection("users")
                .document(Auth.auth().currentUser?.uid ?? "")
                .setData(["name": Auth.auth().currentUser?.displayName ?? ""],
                         merge: true)
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            // Present the main view
            self.performSegue(withIdentifier: "mainViewSegueEmail", sender: nil)
            
        })
    }
    @IBAction func signUpAction(_ sender: Any) {
        performSegue(withIdentifier: "signUpSegue", sender: nil)
    }
}
