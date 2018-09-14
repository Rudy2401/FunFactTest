//
//  LoginViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/24/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class WelcomeViewController: UIViewController {
    @IBOutlet weak var fbSignInButton: ButtonWithShadow!
    @IBOutlet weak var googleSignInButton: ButtonWithShadow!
    @IBOutlet weak var emailSignInButton: ButtonWithShadow!
    @IBOutlet weak var createAccountButton: ButtonWithShadow!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var insideView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        setupButtons()
        
//        insideView.addBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons() {
        fbSignInButton.layer.cornerRadius = 20
        fbSignInButton.layer.backgroundColor = Constants.fbBlueColor.cgColor
        
        let fbSignInLabel1 = String.fontAwesomeIcon(name: .facebook)
        let fbSignInLabelAttr1 = NSAttributedString(string: fbSignInLabel1, attributes: Constants.loginButtonImageBrandAttribute)
        let fbSignInLabelAttrClicked1 = NSAttributedString(string: fbSignInLabel1, attributes: Constants.loginButtonImageBrandClickedAttribute)
        
        let fbSignInLabel2 = " \tSign in with Facebook"
        let fbSignInLabelAttr2 = NSAttributedString(string: fbSignInLabel2, attributes: Constants.loginButtonAttribute)
        let fbSignInLabelAttrClicked2 = NSAttributedString(string: fbSignInLabel2, attributes: Constants.loginButtonClickedAttribute)
        
        let completefbSignInLabel = NSMutableAttributedString()
        completefbSignInLabel.append(fbSignInLabelAttr1)
        completefbSignInLabel.append(fbSignInLabelAttr2)
        
        let completefbSignInLabelClicked = NSMutableAttributedString()
        completefbSignInLabelClicked.append(fbSignInLabelAttrClicked1)
        completefbSignInLabelClicked.append(fbSignInLabelAttrClicked2)
        
        fbSignInButton.setAttributedTitle(completefbSignInLabel, for: .normal)
        fbSignInButton.setAttributedTitle(completefbSignInLabelClicked, for: .highlighted)
        
        googleSignInButton.layer.cornerRadius = 20
        googleSignInButton.layer.backgroundColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        
        let googleSignInLabel2 = "  Sign in with Google"
        let googleSignInLabelAttr2 = NSAttributedString(string: googleSignInLabel2, attributes: Constants.googleLoginButtonAttribute)
        let googleSignInLabelAttrClicked2 = NSAttributedString(string: googleSignInLabel2, attributes: Constants.googleLoginButtonClickedAttribute)
        
        let completegoogleSignInLabel = NSMutableAttributedString()
        completegoogleSignInLabel.append(googleSignInLabelAttr2)
        
        let completegoogleSignInLabelClicked = NSMutableAttributedString()
        completegoogleSignInLabelClicked.append(googleSignInLabelAttrClicked2)
        
        googleSignInButton.setAttributedTitle(completegoogleSignInLabel, for: .normal)
        googleSignInButton.setAttributedTitle(completegoogleSignInLabelClicked, for: .highlighted)
        
        emailSignInButton.layer.cornerRadius = 20
        emailSignInButton.layer.backgroundColor = UIColor(displayP3Red: 180/255, green: 70/255, blue: 25/255, alpha: 1.0).cgColor
        
        let emailSignInLabel1 = String.fontAwesomeIcon(name: .envelope)
        let emailSignInLabelAttr1 = NSAttributedString(string: emailSignInLabel1, attributes: Constants.loginButtonImageSolidAttribute)
        let emailSignInLabelAttrClicked1 = NSAttributedString(string: emailSignInLabel1, attributes: Constants.loginButtonImageSolidClickedAttribute)
        
        let emailSignInLabel2 = " \tSign in with Email"
        let emailSignInLabelAttr2 = NSAttributedString(string: emailSignInLabel2, attributes: Constants.loginButtonAttribute)
        let emailSignInLabelAttrClicked2 = NSAttributedString(string: emailSignInLabel2, attributes: Constants.loginButtonClickedAttribute)
        
        let completeemailSignInLabel = NSMutableAttributedString()
        completeemailSignInLabel.append(emailSignInLabelAttr1)
        completeemailSignInLabel.append(emailSignInLabelAttr2)
        
        let completeemailSignInLabelClicked = NSMutableAttributedString()
        completeemailSignInLabelClicked.append(emailSignInLabelAttrClicked1)
        completeemailSignInLabelClicked.append(emailSignInLabelAttrClicked2)
        
        emailSignInButton.setAttributedTitle(completeemailSignInLabel, for: .normal)
        emailSignInButton.setAttributedTitle(completeemailSignInLabelClicked, for: .highlighted)
        
        createAccountButton.layer.cornerRadius = 20
        createAccountButton.layer.backgroundColor = Constants.forestgreenColor.cgColor
        
        let createAccountLabel1 = String.fontAwesomeIcon(name: .user)
        let createAccountLabelAttr1 = NSAttributedString(string: createAccountLabel1, attributes: Constants.loginButtonImageSolidAttribute)
        let createAccountLabelAttrClicked1 = NSAttributedString(string: createAccountLabel1, attributes: Constants.loginButtonImageSolidClickedAttribute)
        
        let createAccountLabel2 = " \tCreate Account"
        let createAccountLabelAttr2 = NSAttributedString(string: createAccountLabel2, attributes: Constants.loginButtonAttribute)
        let createAccountLabelAttrClicked2 = NSAttributedString(string: createAccountLabel2, attributes: Constants.loginButtonClickedAttribute)
        
        let completecreateAccountLabel = NSMutableAttributedString()
        completecreateAccountLabel.append(createAccountLabelAttr1)
        completecreateAccountLabel.append(createAccountLabelAttr2)
        
        let completecreateAccountLabelClicked = NSMutableAttributedString()
        completecreateAccountLabelClicked.append(createAccountLabelAttrClicked1)
        completecreateAccountLabelClicked.append(createAccountLabelAttrClicked2)
        
        createAccountButton.setAttributedTitle(completecreateAccountLabel, for: .normal)
        createAccountButton.setAttributedTitle(completecreateAccountLabelClicked, for: .highlighted)
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        FBSDKLoginManager().logOut()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                let db = Firestore.firestore()
                db.collection("users").document((Auth.auth().currentUser?.uid)!).setData([
                    "uid": Auth.auth().currentUser?.uid ?? "",
                    "email": Auth.auth().currentUser?.email ?? "",
                    "name": Auth.auth().currentUser?.displayName ?? "",
                    "provider": Auth.auth().currentUser?.providerData[0].providerID ?? "",
                    "photoURL": Auth.auth().currentUser?.photoURL?.absoluteString ?? "",
                    "phoneNumber": Auth.auth().currentUser?.phoneNumber ?? ""
                ]){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                print ("######## Auth successful")
                // Present the main view
                self.performSegue(withIdentifier: "mainViewSegue", sender: nil)
            })
        }
    }
    @IBAction func googleLogin(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
}
extension WelcomeViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            return
        }
        
        guard let authentication = user.authentication else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (user, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            let db = Firestore.firestore()
            db.collection("users").document((Auth.auth().currentUser?.uid)!).setData([
                "uid": Auth.auth().currentUser?.uid ?? "",
                "email": Auth.auth().currentUser?.email ?? "",
                "name": Auth.auth().currentUser?.displayName ?? "",
                "provider": Auth.auth().currentUser?.providerData[0].providerID ?? "",
                "photoURL": Auth.auth().currentUser?.photoURL?.absoluteString ?? "",
                "phoneNumber": Auth.auth().currentUser?.phoneNumber ?? ""
            ]){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            print ("######## Auth successful")
            // Present the main view
            self.performSegue(withIdentifier: "mainViewSegue", sender: nil)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
extension UIView {
    func addBackground(imageName: String = "LoginPage", contentMode: UIViewContentMode = .scaleToFill) {
        // setup the UIImageView
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = contentMode
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundImageView)
        sendSubview(toBack: backgroundImageView)
        
        // adding NSLayoutConstraints
        let leadingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
}
