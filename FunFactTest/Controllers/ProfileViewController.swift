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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "User Profile"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            let photoUrl = Auth.auth().currentUser?.photoURL
            if photoUrl == nil {
                userImageView.image = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: .black, size: CGSize(width: 100, height: 100))
            }
            else {
                let data = try? Data(contentsOf: photoUrl!)
                userImageView.image = UIImage(data: data!)
                
            }
            signInView.isHidden = true
            navigationController?.navigationBar.tintColor = UIColor.darkGray
            userName.text = Auth.auth().currentUser?.displayName
            userProfileName.text = Auth.auth().currentUser?.email?.components(separatedBy: "@")[0]
            userImageView.layer.cornerRadius = userImageView.frame.height/2
            signOutButton.layer.backgroundColor = Constants.redColor.cgColor
            userImageView.layer.borderWidth = 0.5
            userImageView.layer.borderColor = UIColor.gray.cgColor
            
            let db = Firestore.firestore()
            db.collection("funFacts").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if Auth.auth().currentUser?.uid == document.data()["submittedBy"] as? String {
                            self.factsSubmitted += 1
                        }
                    }
                    self.submittedNum.text = String(self.factsSubmitted)
                }
            }
            db.collection("disputes").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if Auth.auth().currentUser?.uid == document.data()["user"] as? String {
                            self.disputesSubmitted += 1
                        }
                    }
                    self.disputesNum.text = String(self.disputesSubmitted)
                }
            }
            
        }
        else {
            signInView.isHidden = false
            view.bringSubview(toFront: signInView)
            signInButton.layer.backgroundColor = Constants.redColor.cgColor
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
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.toolbar.isHidden = true
    }
    
    @IBAction func navigateToWelcomeScreen(_ sender: Any) {
        performSegue(withIdentifier: "welcomeScreenSegue", sender: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.toolbar.isHidden = false
    }
}
