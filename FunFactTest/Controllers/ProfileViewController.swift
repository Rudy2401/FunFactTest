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

class ProfileViewController: UIViewController, FirestoreManagerDelegate, UIScrollViewDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var submittedNum: UILabel!
    @IBOutlet weak var disputesNum: UILabel!
    @IBOutlet weak var signOutButton: CustomButton!
    @IBOutlet weak var signInButton: CustomButton!
    @IBOutlet weak var verifiedNum: UILabel!
    @IBOutlet weak var rejectedNum: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var uid = ""
    var mode = ProfileMode.currentUser
    var factsSubmitted = 0
    var disputesSubmitted = 0
    var funFactsSubmitted = [FunFactMini]()
    var funFactsDisputed = [FunFactMini]()
    var funFactsVerified = [FunFactMini]()
    var funFactsRejected = [FunFactMini]()
    var submittedCount = 0
    var disputeCount = 0
    var verifiedCount = 0
    var rejectedCount = 0
    var photoURL = ""
    var name = ""
    var userNameString = ""
    var levelString = ""
    var firestore = FirestoreManager()
    var userProfile = UserProfile(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, verifiedCount: 0, rejectedCount: 0, email: "", name: "", userName: "", level: "", photoURL: "", provider: "", city: "", country: "", roles: [], funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [], funFactsVerified: [], funFactsRejected: [])
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBarAppearance()
            navBar.backgroundColor = Colors.systemGreenColor
            navBar.titleTextAttributes = Attributes.navTitleAttribute
            navBar.largeTitleTextAttributes = Attributes.navTitleAttribute
            self.navigationController?.navigationBar.standardAppearance = navBar
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBar
            submittedNum.textColor = UIColor.link
        } else {
            submittedNum.textColor = UIColor.blue
        }
        darkModeSupport()
        firestore.delegate = self
        scrollView.delegate = self
        scrollView.accessibilityIdentifier = "profileScrollView"
        submittedNum.accessibilityIdentifier = "submittedNum"
        disputesNum.accessibilityIdentifier = "disputesNum"
        verifiedNum.accessibilityIdentifier = "verifiedNum"
        rejectedNum.accessibilityIdentifier = "rejectedNum"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showFunFact),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        scrollView.alwaysBounceVertical = true
        scrollView.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.insertSubview(refreshControl, at: 0)
        
        navigationItem.title = "User Profile"
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 2)
        scrollView.autoresizingMask = UIView.AutoresizingMask(rawValue:
            UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue)
                | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        scrollView.isUserInteractionEnabled = true
        
        let editLabel1 = String.fontAwesomeIcon(name: .edit)
        let editAttr1 = NSAttributedString(string: editLabel1, attributes: Attributes.navBarImageLightAttribute)
        let editAttrClicked1 = NSAttributedString(string: editLabel1, attributes: Attributes.toolBarImageClickedAttribute)
        
        let completeEditLabel = NSMutableAttributedString()
        completeEditLabel.append(editAttr1)
        
        let completeEditLabelClicked = NSMutableAttributedString()
        completeEditLabelClicked.append(editAttrClicked1)
        
        let edit = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        edit.isUserInteractionEnabled = true
        edit.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        edit.setAttributedTitle(completeEditLabel, for: .normal)
        edit.setAttributedTitle(completeEditLabelClicked, for: .highlighted)
        edit.setAttributedTitle(completeEditLabelClicked, for: .selected)
        edit.titleLabel?.textAlignment = .center
        edit.addTarget(self, action: #selector(editProfileAction), for: .touchUpInside)
        let editBtn = UIBarButtonItem(customView: edit)
        
        if mode == .currentUser {
            navigationItem.setRightBarButtonItems([editBtn], animated: true)
        } else {
            signOutButton.isHidden = true
        }
        if !Auth.auth().currentUser!.isAnonymous {
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
            
            userImageView.layer.cornerRadius = userImageView.frame.height/2
            signOutButton.layer.backgroundColor = Colors.systemGreenColor.cgColor
            
            userImageView.layer.borderWidth = 0.5
            userImageView.layer.borderColor = UIColor.gray.cgColor
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        signInButton.layer.backgroundColor = Colors.systemGreenColor.cgColor
    }
    func darkModeSupport() {
        if traitCollection.userInterfaceStyle == .light {
            scrollView.backgroundColor = .white
            levelLabel.textColor = .darkGray
            locationLabel.textColor = .darkGray
        } else {
            levelLabel.textColor = .white
            locationLabel.textColor = .white
            if #available(iOS 13.0, *) {
                scrollView.backgroundColor = .secondarySystemBackground
            } else {
                scrollView.backgroundColor = .black
            }
        }
    }
    
    @objc func showFunFact() {
        if AppDataSingleton.appDataSharedInstance.url != nil {
            self.tabBarController?.selectedIndex = 0
        }
    }
    @objc func didPullToRefresh() {
        if Auth.auth().currentUser!.isAnonymous {
            return
        }
        self.firestore.downloadUserProfile(Auth.auth().currentUser?.uid ?? "", completionHandler: { (userProfile, error) in
            if let error = error {
                print ("Error getting user profile \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.userProfile = userProfile!
                self.loadAllData()
                self.refreshControl?.endRefreshing()
            }
        })
    }
    @objc func editProfileAction(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "editProfile", sender: sender)
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
            Auth.auth().signInAnonymously(completion: { (res, error) in
                if let error = error {
                    print ("Error signing in anonymously \(error.localizedDescription)")
                }
            })
            self.tabBarController?.selectedIndex = 0
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Auth.auth().currentUser!.isAnonymous  {
            for view in scrollView.subviews {
                view.isHidden = false
            }
            signInButton.isHidden = true
            if mode == .otherUser {
                signOutButton.isHidden = true
            }
        } else {
            for view in scrollView.subviews {
                view.isHidden = true
            }
            signInButton.isHidden = false
            return
        }
        let spinner = Utils.showLoader(view: self.view)
        if AppDataSingleton.appDataSharedInstance.userProfile.uid == "" {
            firestore.downloadUserProfile((Auth.auth().currentUser?.uid) ?? "") { (user, error) in
                if let error = error {
                    print ("Error getting user profile \(error)")
                    spinner.dismissLoader()
                } else {
                    AppDataSingleton.appDataSharedInstance.userProfile = user!
                    self.loadAllData()
                    spinner.dismissLoader()
                }
            }
        } else {
            loadAllData()
            spinner.dismissLoader()
        }
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        darkModeSupport()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    func loadAllData() {
        switch mode {
        case .otherUser:
            submittedCount = userProfile.submittedCount
            disputeCount = userProfile.disputeCount
            verifiedCount = userProfile.verifiedCount
            rejectedCount = userProfile.rejectedCount
            photoURL = userProfile.photoURL
            name = userProfile.name
            userNameString = userProfile.userName
            levelString = userProfile.level
            
        case .currentUser:
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
        if !Auth.auth().currentUser!.isAnonymous {
            self.submittedNum.text = String(submittedCount)
            self.disputesNum.text = String(disputeCount)
            self.verifiedNum.text = String(verifiedCount)
            self.rejectedNum.text = String(rejectedCount)
            
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
            userName.text = name
            var location = ""
            if mode == .currentUser {
                if AppDataSingleton.appDataSharedInstance.userProfile.city == "" {
                    if AppDataSingleton.appDataSharedInstance.userProfile.country.count > 1 {
                        location = AppDataSingleton.appDataSharedInstance.userProfile.country
                    } else {
                        location = "User Location Unknown"
                    }
                }
                else if AppDataSingleton.appDataSharedInstance.userProfile.country == "" {
                    if AppDataSingleton.appDataSharedInstance.userProfile.city.count > 1 {
                        location = AppDataSingleton.appDataSharedInstance.userProfile.city
                    } else {
                        location = "User Location Unknown"
                    }
                } else {
                    location = "\(AppDataSingleton.appDataSharedInstance.userProfile.city), \(AppDataSingleton.appDataSharedInstance.userProfile.country)"
                }
            } else {
                if userProfile.city == "" {
                    if userProfile.country.count > 1 {
                        location = userProfile.country
                    } else {
                        location = "User Location Unknown"
                    }
                }
                else if userProfile.country == "" {
                    if userProfile.city.count > 1 {
                        location = userProfile.city
                    } else {
                        location = "User Location Unknown"
                    }
                } else {
                    location = "\(userProfile.city), \(userProfile.country)"
                }
            }
            
            locationLabel.text = location
            userProfileName.text = userNameString
            levelLabel.text = "Level: \(levelString)"
        }
    }
    
    @objc func subTapAction(sender : UITapGestureRecognizer) {
        if mode == .otherUser {
            firestore.downloadUserProfile(uid) { (userProfile, error) in
                if let error = error {
                    print ("Error getting user profile \(error)")
                } else {
                    let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
                    userSubsVC.userProfile = userProfile
                    userSubsVC.sender = .submissions
                    self.navigationController?.pushViewController(userSubsVC, animated: true)
                }
            }
        } else {
            let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
            userSubsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
            userSubsVC.sender = .submissions
            self.navigationController?.pushViewController(userSubsVC, animated: true)
        }
    }
    @objc func dispTapAction(sender : UITapGestureRecognizer) {
        if mode == .otherUser {
            firestore.downloadUserProfile(uid) { (userProfile, error) in
                if let error = error {
                    print ("Error getting user profile \(error)")
                } else {
                    let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
                    userSubsVC.userProfile = userProfile
                    userSubsVC.sender = .disputes
                    self.navigationController?.pushViewController(userSubsVC, animated: true)
                }
            }
        } else {
            let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
            userSubsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
            userSubsVC.sender = .disputes
            self.navigationController?.pushViewController(userSubsVC, animated: true)
        }
    }
    @objc func verTapAction(sender : UITapGestureRecognizer) {
        if mode == .otherUser {
            firestore.downloadUserProfile(uid) { (userProfile, error) in
                if let error = error {
                    print ("Error getting user profile \(error)")
                } else {
                    let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
                    userSubsVC.userProfile = userProfile
                    userSubsVC.sender = .verifications
                    self.navigationController?.pushViewController(userSubsVC, animated: true)
                }
            }
        } else {
            let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
            userSubsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
            userSubsVC.sender = .verifications
            self.navigationController?.pushViewController(userSubsVC, animated: true)
        }
    }
    @objc func rejTapAction(sender : UITapGestureRecognizer) {
        if mode == .otherUser {
            firestore.downloadUserProfile(uid) { (userProfile, error) in
                if let error = error {
                    print ("Error getting user profile \(error)")
                } else {
                    let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
                    userSubsVC.userProfile = userProfile
                    userSubsVC.sender = .rejections
                    self.navigationController?.pushViewController(userSubsVC, animated: true)
                }
            }
        } else {
            let userSubsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
            userSubsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
            userSubsVC.sender = .rejections
            self.navigationController?.pushViewController(userSubsVC, animated: true)
        }
    }
    
    @IBAction func navigateToWelcomeScreen(_ sender: Any) {
        let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: "firstNav")
        welcomeVC?.modalPresentationStyle = .fullScreen
        self.present(welcomeVC!, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.toolbar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationEditVC = segue.destination as? EditProfileViewController
        destinationEditVC?.fullName = AppDataSingleton.appDataSharedInstance.userProfile.name
        destinationEditVC?.userName = AppDataSingleton.appDataSharedInstance.userProfile.userName
        destinationEditVC?.photoURL = AppDataSingleton.appDataSharedInstance.userProfile.photoURL
        destinationEditVC?.city = AppDataSingleton.appDataSharedInstance.userProfile.city
        destinationEditVC?.country = AppDataSingleton.appDataSharedInstance.userProfile.country
    }
}
