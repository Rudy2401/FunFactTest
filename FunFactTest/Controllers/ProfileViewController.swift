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
    
    var factsSubmitted = 0
    var disputesSubmitted = 0
    var userProfile = User(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, email: "", name: "", phoneNumber: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [])
    var funFactsSubmitted = [FunFact]()
    var landmarksDict = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "User Profile"
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
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.toolbar.isHidden = true
        if Auth.auth().currentUser != nil {
            downloadUserProfile() { (user) in
                self.userProfile = user
            }
//        }
        
//        if self.userProfile.uid != nil && self.userProfile.uid != "" && Auth.auth().currentUser != nil {
        
            let subGesture = UITapGestureRecognizer(target: self, action: #selector(subTapAction))
            subGesture.numberOfTapsRequired = 1
            submittedNum.isUserInteractionEnabled = true
            submittedNum.addGestureRecognizer(subGesture)
            
            let photoUrl = URL(string: userProfile.photoURL ?? "")
            if photoUrl == URL(string: "") {
                userImageView.image = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: .black, size: CGSize(width: 100, height: 100))
            }
            else {
                let data = try? Data(contentsOf: photoUrl!)
                userImageView.image = UIImage(data: data!)
                
            }
            signInView.isHidden = true
            navigationController?.navigationBar.tintColor = UIColor.darkGray
            userName.text = userProfile.name
            userProfileName.text = userProfile.email.components(separatedBy: "@")[0]
            userImageView.layer.cornerRadius = userImageView.frame.height/2
            signOutButton.layer.backgroundColor = Constants.redColor.cgColor
            userImageView.layer.borderWidth = 0.5
            userImageView.layer.borderColor = UIColor.gray.cgColor
            
            let db = Firestore.firestore()
            db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (snapshot, error) in
                if let document = snapshot {
                    self.factsSubmitted = document.data()?["submittedCount"] as! Int
                    self.disputesSubmitted = document.data()?["disputeCount"] as! Int
                    self.submittedNum.text = String(self.factsSubmitted)
                    self.disputesNum.text = String(self.disputesSubmitted)
                } else {
                    print("Document does not exist")
                }
            }
            
            for ref in (userProfile.funFactsSubmitted) {
                downloadFunFactsSubmitted(ref: ref, completionHandler: { (funFact) in
                    let f = funFact
                    self.funFactsSubmitted.append(f)
                })
            }
            
            populateLandmarkDict() { (dict) in
                self.landmarksDict = dict
            }
        }
        else {
            signInView.isHidden = false
            view.bringSubviewToFront(signInView)
            signInButton.layer.backgroundColor = Constants.redColor.cgColor
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
        subViewVC?.userProfile = userProfile
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
        var funFact = FunFact(landmarkId: "", id: "", description: "", likes: 0, dislikes: 0, verificationFlag: "", image: "", imageCaption: "", disputeFlag: "", submittedBy: "", dateSubmitted: "", source: "", tags: [])
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
                                      tags: document.data()?["tags"] as! [String])
                completionHandler(funFact)
            } else {
                print("Document \(ref.documentID) does not exist")
            }
        }
    }
    
    func downloadUserProfile(completionHandler: @escaping (User) -> ())  {
        if Auth.auth().currentUser == nil {
            return
        }
        let db = Firestore.firestore()
        var user = User(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, email: "", name: "", phoneNumber: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [])
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (snapshot, error) in
            if let document = snapshot {
                user.dislikeCount = document.data()?["dislikeCount"] as! Int
                user.likeCount = document.data()?["likeCount"] as! Int
                user.disputeCount = document.data()?["disputeCount"] as! Int
                user.submittedCount = document.data()?["submittedCount"] as! Int
                user.email = document.data()?["email"] as! String
                user.name = document.data()?["name"] as! String
                user.phoneNumber = document.data()?["phoneNumber"] as! String
                user.photoURL = document.data()?["photoURL"] as! String
                user.provider = document.data()?["provider"] as! String
                user.uid = document.data()?["uid"] as! String
                
                self.downloadOtherUserData(collection: "funFactsLiked", completionHandler: { (ref) in
                    self.userProfile.funFactsLiked = ref
                })
                self.downloadOtherUserData(collection: "funFactsDisliked", completionHandler: { (ref) in
                    self.userProfile.funFactsDisliked = ref
                })
                self.downloadOtherUserData(collection: "funFactsSubmitted", completionHandler: { (ref) in
                    self.userProfile.funFactsSubmitted = ref
                })
                self.downloadOtherUserData(collection: "funFactsDisputed", completionHandler: { (ref) in
                    self.userProfile.funFactsDisputed = ref
                })
                
                completionHandler(user)
            }
            else {
                let err = error
                print("Error getting documents: \(String(describing: err))")
            }
        }
    }
    func downloadOtherUserData(collection: String, completionHandler: @escaping ([DocumentReference]) -> ()) {
        var refs = [DocumentReference]()
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").collection(collection).getDocuments() { (snap, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for doc in snap!.documents {
                    if collection == "funFactsDisputed" {
                        refs.append(doc.data()["disputeID"] as! DocumentReference)
                    } else {
                        refs.append(doc.data()["funFactID"] as! DocumentReference)
                    }
                }
            }
            completionHandler(refs)
        }
    }
}
