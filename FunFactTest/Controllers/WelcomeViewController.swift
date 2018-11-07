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
    @IBOutlet weak var guestButton: ButtonWithShadow!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var insideView: UIView!
    @IBOutlet weak var welcomeTitle: UILabel!
    
    var signedInView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        if let currentUser = Auth.auth().currentUser {
            currentUser.getIDTokenForcingRefresh(true) { (con, error) in
                if let error = error {
                    do {
                        try Auth.auth().signOut()
                        print ("token error = \(error)")
                    }
                    catch let error as NSError {
                        print (error.localizedDescription)
                    }
                    return
                }
            }
        }
        
        if Auth.auth().currentUser != nil && (Auth.auth().currentUser?.isEmailVerified)! {
            // User is signed in.
            insideView.isHidden = true
            signedInView = UIView(frame: self.view.frame)
            signedInView?.addBackground()
            let labelText = "Fun Facts"
            let label = UILabel(frame: CGRect(x: 20, y: (signedInView?.frame.height)!/2, width: (signedInView?.frame.width)!-40, height: 60))
            label.textAlignment = .center
            label.font = UIFont(name: "AvenirNext-Bold", size: 35)
            label.text = labelText
            signedInView?.addSubview(label)
            self.view.addSubview(signedInView!)
            self.performSegue(withIdentifier: "mainViewSegue", sender: nil)
        } else {
            // No user is signed in.
            do {
                try Auth.auth().signOut()
            }
            catch let error as NSError {
                print (error.localizedDescription)
            }
            insideView.isHidden = false
            signedInView?.isHidden = true
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            setupButtons()
            anotherAnimateLabel()
            insideView.addBackground()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func anotherAnimateLabel() {
        if welcomeTitle.center != CGPoint(x:50, y:10) {
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: .transitionCurlDown, animations: { () -> Void in
                self.welcomeTitle.center = CGPoint(x:100, y:70)
            }, completion: nil)
        }
        welcomeTitle.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        welcomeTitle.layer.shadowOffset = CGSize(width: 0, height: 3)
        welcomeTitle.layer.shadowOpacity = 1.0
        welcomeTitle.layer.shadowRadius = 10.0
        welcomeTitle.layer.masksToBounds = false
    }
    
    func animateLabel() {
        var bounds = welcomeTitle.bounds
        welcomeTitle.font = welcomeTitle.font.withSize(50)
        bounds.size = welcomeTitle.intrinsicContentSize
        welcomeTitle.bounds = bounds
        let scaleX = welcomeTitle.frame.size.width / bounds.size.width
        let scaleY = welcomeTitle.frame.size.height / bounds.size.height
        welcomeTitle.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        UIView.animate(withDuration: 1.0) {
            self.welcomeTitle.transform = .identity
        }
        let labelCopy = welcomeTitle.copyLabel()
        labelCopy.font = welcomeTitle.font.withSize(35)
        var bounds1 = labelCopy.bounds
        bounds1.size = labelCopy.intrinsicContentSize
        let scaleX1 = bounds1.size.width / welcomeTitle.frame.size.width
        let scaleY1 = bounds1.size.height / welcomeTitle.frame.size.height
        UIView.animate(withDuration: 1.0, animations: {
            self.welcomeTitle.transform = CGAffineTransform(scaleX: scaleX1, y: scaleY1)
        }, completion: { done in
            self.welcomeTitle.font = labelCopy.font
            self.welcomeTitle.transform = .identity
            self.welcomeTitle.bounds = bounds
        })
        welcomeTitle.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        welcomeTitle.layer.shadowOffset = CGSize(width: 0, height: 3)
        welcomeTitle.layer.shadowOpacity = 1.0
        welcomeTitle.layer.shadowRadius = 10.0
        welcomeTitle.layer.masksToBounds = false
    }
    
    func setupButtons() {
        fbSignInButton.layer.cornerRadius = 25
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
        
        googleSignInButton.layer.cornerRadius = 25
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
        
        emailSignInButton.layer.cornerRadius = 25
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
        
        guestButton.layer.cornerRadius = 25
        guestButton.layer.backgroundColor = UIColor.darkGray.cgColor
        
        let createAccountLabel1 = String.fontAwesomeIcon(name: .user)
        let createAccountLabelAttr1 = NSAttributedString(string: createAccountLabel1, attributes: Constants.loginButtonImageSolidAttribute)
        let createAccountLabelAttrClicked1 = NSAttributedString(string: createAccountLabel1, attributes: Constants.loginButtonImageSolidClickedAttribute)
        
        let createAccountLabel2 = " \tContinue as Guest"
        let createAccountLabelAttr2 = NSAttributedString(string: createAccountLabel2, attributes: Constants.loginButtonAttribute)
        let createAccountLabelAttrClicked2 = NSAttributedString(string: createAccountLabel2, attributes: Constants.loginButtonClickedAttribute)
        
        let completecreateAccountLabel = NSMutableAttributedString()
        completecreateAccountLabel.append(createAccountLabelAttr1)
        completecreateAccountLabel.append(createAccountLabelAttr2)
        
        let completecreateAccountLabelClicked = NSMutableAttributedString()
        completecreateAccountLabelClicked.append(createAccountLabelAttrClicked1)
        completecreateAccountLabelClicked.append(createAccountLabelAttrClicked2)
        
        guestButton.setAttributedTitle(completecreateAccountLabel, for: .normal)
        guestButton.setAttributedTitle(completecreateAccountLabelClicked, for: .highlighted)
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
                print ("######## Auth successful")
                // Present the main view
                self.performSegue(withIdentifier: "mainViewSegue", sender: nil)
            })
        }
    }
    @IBAction func googleLogin(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func guestAction(_ sender: Any) {
        self.performSegue(withIdentifier: "mainViewSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
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

            print ("######## Auth successful")
            // Present the main view
            self.performSegue(withIdentifier: "mainViewSegue", sender: nil)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

extension UILabel {
    func copyLabel() -> UILabel {
        let label = UILabel()
        label.font = self.font
        label.frame = self.frame
        label.text = self.text
        return label
    }
}
