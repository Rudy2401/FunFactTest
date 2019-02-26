//
//  ProfileViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 9/5/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, FirestoreManagerDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var submittedNum: UILabel!
    @IBOutlet weak var disputesNum: UILabel!
    @IBOutlet weak var signOutButton: CustomButton!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var signInButton: CustomButton!
    @IBOutlet weak var verifiedNum: UILabel!
    @IBOutlet weak var rejectedNum: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    var uid = ""
    var mode = ""
    var factsSubmitted = 0
    var disputesSubmitted = 0
    var funFactsSubmitted = [FunFact]()
    var funFactsDisputed = [FunFact]()
    var funFactsVerified = [FunFact]()
    var funFactsRejected = [FunFact]()
    var landmarksDict = [String: String]()
    var submittedCount = 0
    var disputeCount = 0
    var verifiedCount = 0
    var rejectedCount = 0
    var photoURL = ""
    var name = ""
    var userNameString = ""
    var levelString = ""
    var firestore = FirestoreManager()
    var userProfile = UserProfile(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, verifiedCount: 0, rejectedCount: 0, email: "", name: "", userName: "", level: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [], funFactsVerified: [], funFactsRejected: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        submittedNum.textColor = Colors.blueColor
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: customFont
            ]
        }
        navigationItem.title = "User Profile"
        
        firestore.populateLandmarkDict() { (dict) in
            self.landmarksDict = dict
        }
    }
    func documentsDidUpdate() {
        print("downloaded")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signOutAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Sign Out",
                                                message: "Are you sure you want to sign out?",
                                                preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            do {
                try Auth.auth().signOut()
                self.tabBarController?.selectedIndex = 0
            }
            catch let error as NSError {
                print (error.localizedDescription)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mode == "other" {
            submittedCount = userProfile.submittedCount
            disputeCount = userProfile.disputeCount
            verifiedCount = userProfile.verifiedCount
            rejectedCount = userProfile.rejectedCount
            photoURL = userProfile.photoURL
            name = userProfile.name
            userNameString = userProfile.userName
            levelString = userProfile.level
            
        }
        else {
            submittedCount = AppDataSingleton.appDataSharedInstance.userProfile.submittedCount
            disputeCount = AppDataSingleton.appDataSharedInstance.userProfile.disputeCount
            verifiedCount = AppDataSingleton.appDataSharedInstance.userProfile.verifiedCount
            rejectedCount = AppDataSingleton.appDataSharedInstance.userProfile.rejectedCount
            photoURL = AppDataSingleton.appDataSharedInstance.userProfile.photoURL
            name = AppDataSingleton.appDataSharedInstance.userProfile.name
            userNameString = AppDataSingleton.appDataSharedInstance.userProfile.userName
            levelString = AppDataSingleton.appDataSharedInstance.userProfile.level
        }
        // Hide the navigation bar on the this view controller
        self.navigationController?.toolbar.isHidden = true
        if Auth.auth().currentUser != nil {
            self.submittedNum.text = String(submittedCount)
            self.disputesNum.text = String(disputeCount)
            self.verifiedNum.text = String(verifiedCount)
            self.rejectedNum.text = String(rejectedCount)
            
            let subGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(subTapAction))
            subGesture.numberOfTapsRequired = 1
            submittedNum.isUserInteractionEnabled = true
            submittedNum.addGestureRecognizer(subGesture)
            
            let dispGesture = UITapGestureRecognizer(target: self,
                                                     action: #selector(dispTapAction))
            dispGesture.numberOfTapsRequired = 1
            disputesNum.isUserInteractionEnabled = true
            disputesNum.addGestureRecognizer(dispGesture)
            
            let verGesture = UITapGestureRecognizer(target: self,
                                                     action: #selector(verTapAction))
            verGesture.numberOfTapsRequired = 1
            verifiedNum.isUserInteractionEnabled = true
            verifiedNum.addGestureRecognizer(verGesture)
            
            let rejGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(rejTapAction))
            rejGesture.numberOfTapsRequired = 1
            rejectedNum.isUserInteractionEnabled = true
            rejectedNum.addGestureRecognizer(rejGesture)
            
            let photoUrl = URL(string: photoURL )
            if photoUrl == URL(string: "") {
                userImageView.image = UIImage.fontAwesomeIcon(name: .user,
                                                              style: .solid,
                                                              textColor: .black,
                                                              size: CGSize(width: 100, height: 100))
            }
            else {
                let data = try? Data(contentsOf: photoUrl!)
                if data == nil {
                    userImageView.image = UIImage
                        .fontAwesomeIcon(name: .user,
                                         style: .solid,
                                         textColor: .darkGray,
                                         size: CGSize(width: 100, height: 100))
                } else {
                    userImageView.image = UIImage(data: data!)
                }
            }
            signInView.isHidden = true
            navigationController?.navigationBar.tintColor = UIColor.darkGray
            userName.text = name
            userProfileName.text = userNameString
            levelLabel.text = "Level: \(levelString)"
            userImageView.layer.cornerRadius = userImageView.frame.height/2
            signOutButton.layer.backgroundColor = Colors.seagreenColor.cgColor
            userImageView.layer.borderWidth = 0.5
            userImageView.layer.borderColor = UIColor.gray.cgColor
        }
        else {
            signInView.isHidden = false
            view.bringSubviewToFront(signInView)
            signInButton.layer.backgroundColor = Colors.seagreenColor.cgColor
        }
    }
    
    @objc func subTapAction(sender : UITapGestureRecognizer) {
        if mode == "other" {
            firestore.downloadUserProfile(uid) { (userProfile) in
                let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! UserSubsTableViewController
                userSubsVC.userProfile = userProfile
                userSubsVC.funFacts = self.funFactsSubmitted
                userSubsVC.sender = "sub"
                userSubsVC.landmarksDict = self.landmarksDict
                self.navigationController?.pushViewController(userSubsVC, animated: true)
            }
        } else {
            let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! UserSubsTableViewController
            userSubsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
            userSubsVC.funFacts = self.funFactsSubmitted
            userSubsVC.sender = "sub"
            userSubsVC.landmarksDict = self.landmarksDict
            self.navigationController?.pushViewController(userSubsVC, animated: true)
        }
    }
    @objc func dispTapAction(sender : UITapGestureRecognizer) {
        if mode == "other" {
            firestore.downloadUserProfile(uid) { (userProfile) in
                let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! UserSubsTableViewController
                userSubsVC.userProfile = userProfile
                userSubsVC.funFacts = self.funFactsSubmitted
                userSubsVC.sender = "disp"
                userSubsVC.landmarksDict = self.landmarksDict
                self.navigationController?.pushViewController(userSubsVC, animated: true)
            }
        } else {
            let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! UserSubsTableViewController
            userSubsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
            userSubsVC.funFacts = self.funFactsSubmitted
            userSubsVC.sender = "disp"
            userSubsVC.landmarksDict = self.landmarksDict
            self.navigationController?.pushViewController(userSubsVC, animated: true)
        }
    }
    @objc func verTapAction(sender : UITapGestureRecognizer) {
        if mode == "other" {
            firestore.downloadUserProfile(uid) { (userProfile) in
                let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! UserSubsTableViewController
                userSubsVC.userProfile = userProfile
                userSubsVC.funFacts = self.funFactsSubmitted
                userSubsVC.sender = "ver"
                userSubsVC.landmarksDict = self.landmarksDict
                self.navigationController?.pushViewController(userSubsVC, animated: true)
            }
        } else {
            let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! UserSubsTableViewController
            userSubsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
            userSubsVC.funFacts = self.funFactsSubmitted
            userSubsVC.sender = "ver"
            userSubsVC.landmarksDict = self.landmarksDict
            self.navigationController?.pushViewController(userSubsVC, animated: true)
        }
    }
    @objc func rejTapAction(sender : UITapGestureRecognizer) {
        if mode == "other" {
            firestore.downloadUserProfile(uid) { (userProfile) in
                let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! UserSubsTableViewController
                userSubsVC.userProfile = userProfile
                userSubsVC.funFacts = self.funFactsSubmitted
                userSubsVC.sender = "rej"
                userSubsVC.landmarksDict = self.landmarksDict
                self.navigationController?.pushViewController(userSubsVC, animated: true)
            }
        } else {
            let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! UserSubsTableViewController
            userSubsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
            userSubsVC.funFacts = self.funFactsSubmitted
            userSubsVC.sender = "rej"
            userSubsVC.landmarksDict = self.landmarksDict
            self.navigationController?.pushViewController(userSubsVC, animated: true)
        }
    }
    
    @IBAction func navigateToWelcomeScreen(_ sender: Any) {
        performSegue(withIdentifier: "welcomeScreenSegue", sender: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.toolbar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}
