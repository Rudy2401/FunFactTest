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

class ProfileViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var submittedNum: UILabel!
    @IBOutlet weak var disputesNum: UILabel!
    @IBOutlet weak var signOutButton: CustomButton!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var signInButton: CustomButton!
    
    var uid = ""
    var mode = ""
    var factsSubmitted = 0
    var disputesSubmitted = 0
    var funFactsSubmitted = [FunFact]()
    var landmarksDict = [String: String]()
    var submittedCount = 0
    var disputeCount = 0
    var photoURL = ""
    var name = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        submittedNum.textColor = Colors.blueColor
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: customFont ]
        }
        navigationItem.title = "User Profile"
        var funFactsSubmitted = [DocumentReference]()
        if mode == "other" {
            funFactsSubmitted = AppDataSingleton.appDataSharedInstance.usersDict[uid]?.funFactsSubmitted ?? [DocumentReference]()
        }
        else {
            funFactsSubmitted = AppDataSingleton.appDataSharedInstance.userProfile.funFactsSubmitted
        }
        
        for ref in funFactsSubmitted {
            downloadFunFactsSubmitted(ref: ref, completionHandler: { (funFact) in
                let f = funFact
                self.funFactsSubmitted.append(f)
            })
        }
        
        populateLandmarkDict() { (dict) in
            self.landmarksDict = dict
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        }
        catch let error as NSError {
            print (error.localizedDescription)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mode == "other" {
            submittedCount = AppDataSingleton.appDataSharedInstance.usersDict[uid]?.submittedCount ?? 0
            disputeCount = AppDataSingleton.appDataSharedInstance.usersDict[uid]?.disputeCount ?? 0
            photoURL = AppDataSingleton.appDataSharedInstance.usersDict[uid]?.photoURL ?? ""
            name = AppDataSingleton.appDataSharedInstance.usersDict[uid]?.name ?? ""
            email = AppDataSingleton.appDataSharedInstance.usersDict[uid]?.email ?? ""
        }
        else {
            submittedCount = AppDataSingleton.appDataSharedInstance.userProfile.submittedCount
            disputeCount = AppDataSingleton.appDataSharedInstance.userProfile.disputeCount
            photoURL = AppDataSingleton.appDataSharedInstance.userProfile.photoURL
            name = AppDataSingleton.appDataSharedInstance.userProfile.name
            email = AppDataSingleton.appDataSharedInstance.userProfile.email
        }
        
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.toolbar.isHidden = true
        if Auth.auth().currentUser != nil {
        
//        if self.userProfile.uid != nil && self.userProfile.uid != "" && Auth.auth().currentUser != nil {
//            let mainTab = self.tabBarController?.viewControllers?.first as? MainViewController
//            self.userProfile = (mainTab?.userProfile)!
//            print (mainTab?.listOfFunFacts.listOfFunFacts.count)
            
            self.submittedNum.text = String(submittedCount)
            self.disputesNum.text = String(disputeCount)
            
            let subGesture = UITapGestureRecognizer(target: self, action: #selector(subTapAction))
            subGesture.numberOfTapsRequired = 1
            submittedNum.isUserInteractionEnabled = true
            submittedNum.addGestureRecognizer(subGesture)
            
            let photoUrl = URL(string: photoURL )
            if photoUrl == URL(string: "") {
                userImageView.image = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: .black, size: CGSize(width: 100, height: 100))
            }
            else {
                let data = try? Data(contentsOf: photoUrl!)
                userImageView.image = UIImage(data: data!)
                
            }
            signInView.isHidden = true
            navigationController?.navigationBar.tintColor = UIColor.darkGray
            userName.text = name
            userProfileName.text = email.components(separatedBy: "@")[0]
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
        performSegue(withIdentifier: "subViewDetail", sender: nil)
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
        let subViewVC = segue.destination as? UserSubsTableViewController
        if mode == "other" {
            subViewVC?.userProfile = AppDataSingleton.appDataSharedInstance.usersDict[uid]
        }
        else {
            subViewVC?.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
        }
        
        subViewVC?.funFactsSubmitted = funFactsSubmitted
        subViewVC?.landmarksDict = landmarksDict
    }
    
    func populateLandmarkDict(completionHandler: @escaping ([String:String]) -> ()) {
        let db = Firestore.firestore()
        var landmarkDict = [String:String]()
        db.collection("landmarks").getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print ("Error \(error)")
            }
            else {
                for document in snapshot!.documents {
                    landmarkDict[document.data()["id"] as! String] = document.data()["name"] as? String
                }
                completionHandler(landmarkDict)
            }
        })
        
    }
    
    func downloadFunFactsSubmitted(ref: DocumentReference, completionHandler: @escaping (FunFact) -> ())  {
        var funFact = FunFact(landmarkId: "", id: "", description: "", likes: 0, dislikes: 0, verificationFlag: "", image: "", imageCaption: "", disputeFlag: "", submittedBy: "", dateSubmitted: "", source: "", tags: [], approvalCount: 0, rejectionCount: 0, approvalUsers: [], rejectionUsers: [])
        ref.getDocument { (snapshot, error) in
            if let document = snapshot, document.exists {
                funFact = FunFact(landmarkId: document.data()?["landmarkId"] as! String,
                                      id: document.data()?["id"] as! String,
                                      description: document.data()?["description"] as! String,
                                      likes: document.data()?["likes"] as! Int,
                                      dislikes: document.data()?["dislikes"] as! Int,
                                      verificationFlag: document.data()?["verificationFlag"] as? String ?? "",
                                      image: document.data()?["imageName"] as! String,
                                      imageCaption: document.data()?["imageCaption"] as? String ?? "",
                                      disputeFlag: document.data()?["disputeFlag"] as! String,
                                      submittedBy: document.data()?["submittedBy"] as! String,
                                      dateSubmitted: document.data()?["dateSubmitted"] as! String,
                                      source: document.data()?["source"] as! String,
                                      tags: document.data()?["tags"] as! [String],
                                      approvalCount: document.data()?["approvalCount"] as! Int,
                                      rejectionCount: document.data()?["rejectionCount"] as! Int,
                                      approvalUsers: document.data()?["approvalUsers"] as! [String],
                                      rejectionUsers: document.data()?["rejectionUsers"] as! [String])
                completionHandler(funFact)
            } else {
                print("Document \(ref.documentID) does not exist")
            }
        }
    }
}
