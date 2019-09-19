//
//  ContentViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/27/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class ContentViewController: UIViewController, FirestoreManagerDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var funFactDescriptionTextView: UITextView!
    @IBOutlet weak var landmarkImage: UIImageView!
    @IBOutlet weak var submittedBy: UILabel!
    @IBOutlet weak var likeHeart: UIButton!
    @IBOutlet weak var dislikeHeart: UIButton!
    @IBOutlet weak var sourceURL: UITextView!
    @IBOutlet weak var dispute: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var dislikeCount: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageCaptionLabel: UILabel!
    
    let util = Utils()
    var funFact = FunFact(landmarkId: "",
                          landmarkName: "",
                          id: "",
                          description: "",
                          funFactTitle: "",
                          likes: 0,
                          dislikes: 0,
                          verificationFlag: "",
                          image: "",
                          imageCaption: "",
                          disputeFlag: "",
                          submittedBy: "",
                          dateSubmitted: Timestamp(date: Date()),
                          source: "",
                          tags: [],
                          approvalCount: 0,
                          rejectionCount: 0,
                          approvalUsers: [],
                          rejectionUsers: [],
                          rejectionReason: [])
    var landmarkID = ""
    var address: String = ""
    var currPageNumberText = ""
    var totalPageNumberText = ""
    var quickHelpView = UIAlertController()
    var popup = UIAlertController()
    var firestore = FirestoreManager()
    var stack = UIStackView()
    var refreshControl: UIRefreshControl!
    var sender = Sender.regular
    var funFactMini = FunFactMini(landmarkName: "", id: "", description: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceURL.isScrollEnabled = false
        scrollView.backgroundColor = .white
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
        
        view.backgroundColor = .white
        
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(viewImageViewer))
        imageGesture.numberOfTapsRequired = 1
        landmarkImage.isUserInteractionEnabled = true
        landmarkImage.addGestureRecognizer(imageGesture)
        
        funFactDescriptionTextView.layer.borderWidth = 0
        funFactDescriptionTextView.isEditable = false
        funFactDescriptionTextView.isScrollEnabled = false
        funFactDescriptionTextView.delegate = self
        funFactDescriptionTextView.sizeToFit()
        
        if funFact.verificationFlag == "N" {
            setupVerificationPage()
        } else if funFact.verificationFlag == "R" {
            setupDisputeRejectedPage()
        }
        if funFact.disputeFlag == "Y" {
            setupDisputeRejectedPage()
        }
        if (self.navigationController?.presentingViewController as? FunFactPageViewController) != nil {
            let addFactGesture = UITapGestureRecognizer(target: self, action: #selector(viewAddFactForLandmark))
            addFactGesture.numberOfTapsRequired = 1
            let button = navigationController?.toolbar.items?[2].customView as! UIButton // swiftlint:disable:this force_cast
            button.addGestureRecognizer(addFactGesture)
        } else {
//            navigationItem.title = funF
        }
    }
    
    @IBAction func likeIt(_ sender: Any) {
        if Auth.auth().currentUser!.isAnonymous {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to like/dislike a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.darkGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: Colors.redColor) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(Colors.seagreenColor, for: .normal)
            
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .light)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(.darkGray, for: .normal)
            firestore.addLikes(funFact: funFact, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
            firestore.deleteDislikes(funFactID: funFact.id, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.darkGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.darkGray) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(Colors.seagreenColor, for: .normal)
            firestore.addLikes(funFact: funFact, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
            
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: Colors.seagreenColor)
            && Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.darkGray) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .light)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(.darkGray, for: .normal)
            firestore.deleteLikes(funFactID: funFact.id, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        }
        didPullToRefresh()
    }
    
    @IBAction func dislikeIt(_ sender: Any) {
        if Auth.auth().currentUser!.isAnonymous {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to like/dislike a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.darkGray)
            &&  Utils.compareColors(c1: likeHeart.currentTitleColor, c2: Colors.seagreenColor) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .light)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(.darkGray, for: .normal)
            
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(Colors.redColor, for: .normal)
            firestore.addDislikes(funFact: funFact, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
            firestore.deleteLikes(funFactID: funFact.id, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.darkGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.darkGray) {
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(Colors.redColor, for: .normal)
            firestore.addDislikes(funFact: funFact, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: Colors.redColor)
            && Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.darkGray) {
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .light)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(.darkGray, for: .normal)
            firestore.deleteDislikes(funFactID: funFact.id, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        }
        didPullToRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if sender == .table {
            firestore.downloadFunFact(for: funFactMini.id) { (funFact, error) in
                if let error = error {
                    print ("Error getting fun fact \(error)")
                } else {
                    self.funFact = funFact!
                    self.landmarkID = funFact?.landmarkId ?? ""
                    self.setupImage()
                    self.populatefunFactDesc()
                    self.setupVerifScreen()
                    self.setupImageCaption()
                    self.setupSubmittedBy()
                    self.setupSource()
                    self.setupDisputes()
                    self.setupLikesAndDislikes()
                }
            }
        } else {
            setupImage()
            populatefunFactDesc()
            setupVerifScreen()
            setupImageCaption()
            setupSubmittedBy()
            setupSource()
            setupDisputes()
            setupLikesAndDislikes()
        }
    }
    func setupImageCaption() {
        imageCaptionLabel.text = funFact.imageCaption
    }
    func setupVerifScreen() {
        if funFact.verificationFlag == "N" {
            likeHeart.isHidden = true
            dislikeHeart.isHidden = true
            likeCount.isHidden = true
            dislikeCount.isHidden = true
            dispute.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.sourceURL.transform = CGAffineTransform(translationX: 0, y: -50)
                self.submittedBy.transform = CGAffineTransform(translationX: 0, y: -50)
                self.stack.transform = CGAffineTransform(translationX: 0, y: -50)
            }, completion: nil)
        }
    }
    func setupSubmittedBy() {
        let submittedBy1 = "Submitted By: "
        let myAttrString1 = NSAttributedString(string: submittedBy1, attributes: Attributes.attribute12BoldDG)
        self.submittedBy.attributedText = myAttrString1
        firestore.downloadUserProfile(funFact.submittedBy) { (userProfile, error) in
            if let error = error {
                print ("Error getting user profile \(error)")
            } else {
                let submittedBy1 = "Submitted By: "
                let myAttrString1 = NSAttributedString(string: submittedBy1, attributes: Attributes.attribute12BoldDG)
                let completeSubmittedBy = NSMutableAttributedString()
                let userID = userProfile!.userName
                let submittedBy2 = userID
                let myAttrString2 = NSAttributedString(string: submittedBy2, attributes: Attributes.attribute12RegBlue)
                let profileGesture = UITapGestureRecognizer(target: self, action: #selector(self.profileView))
                profileGesture.numberOfTapsRequired = 1
                
                self.submittedBy.isUserInteractionEnabled = true
                self.submittedBy.addGestureRecognizer(profileGesture)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let date = self.funFact.dateSubmitted
                let date1 = dateFormatter.string(from: date.dateValue())
                let myAttrString3 = NSAttributedString(string: ", \(date1)", attributes: Attributes.attribute10RegDG)
                
                completeSubmittedBy.append(myAttrString1)
                completeSubmittedBy.append(myAttrString2)
                completeSubmittedBy.append(myAttrString3)
                self.submittedBy.frame.size = self.submittedBy.intrinsicContentSize
                self.submittedBy.attributedText = completeSubmittedBy
            }
        }
    }
    func setupSource() {
        let source1 = "Source: "
        let sourceAtt1 = NSMutableAttributedString(string: source1)
        sourceAtt1.addAttributes(Attributes.attribute12BoldDG, range: (source1 as NSString).range(of: source1))
        let source2 = funFact.source
        var substring = ""
        if source2.count > 40 {
            let index = source2.index(source2.startIndex, offsetBy: 40)
            substring = source2[...index] + "..."
        } else {
            substring = source2
        }
        let sourceAtt2 = NSMutableAttributedString(string: substring)
        sourceAtt2.addAttributes(Attributes.attribute12RegDG, range: (substring as NSString).range(of: substring))
        sourceAtt2.addAttribute(.link, value: source2, range: NSRange(location: 0, length: substring.count))
        let attributedString = NSMutableAttributedString()
        attributedString.append(sourceAtt1)
        attributedString.append(sourceAtt2)
        
        sourceURL.attributedText = attributedString
        
        sourceURL.isEditable = false
        sourceURL.dataDetectorTypes = .link
        sourceURL.textContainerInset = UIEdgeInsets.zero
        sourceURL.textContainer.lineFragmentPadding = 0
        sourceURL.textAlignment = .center
    }
    func setupDisputes() {
        let disAttribute = [ NSAttributedString.Key.foregroundColor: Colors.blueColor,
                             NSAttributedString.Key.font: UIFont(name: Fonts.regularFont, size: 12.0)!] as [NSAttributedString.Key: Any]
        let dispute1 = "See something wrong? Dispute this fact "
        let disAttrString1 = NSAttributedString(string: dispute1, attributes: Attributes.attribute12RegDG)
        
        let disputeArrow = String.fontAwesomeIcon(name: .arrowRight)
        let disputeArrowString = NSAttributedString(string: disputeArrow, attributes: Attributes.smallImageAttribute)
        
        let dispute2 = " Here"
        let disAttrString2 = NSAttributedString(string: dispute2, attributes: disAttribute)
        
        let completeDispute = NSMutableAttributedString()
        completeDispute.append(disAttrString1)
        completeDispute.append(disputeArrowString)
        completeDispute.append(disAttrString2)
        
        dispute.attributedText = completeDispute
        let disputeGesture = UITapGestureRecognizer(target: self, action: #selector(disputeTapAction))
        disputeGesture.numberOfTapsRequired = 1
        dispute.addGestureRecognizer(disputeGesture)
        dispute.isUserInteractionEnabled = true
    }
    func setupLikesAndDislikes() {
        likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .light)
        likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
        likeCount.text = "\(funFact.likes)" + " likes"
        dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .light)
        dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
        dislikeCount.text = "\(funFact.dislikes)" + " dislikes"
        
        firestore.hasUserLikedOrDisliked(uid: Auth.auth().currentUser?.uid ?? "",
                                         funFactID: funFact.id,
                                         collection: "funFactsLiked") { (hasLiked, error) in
                                            if hasLiked! {
                                                self.likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
                                                self.likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
                                                self.likeHeart.setTitleColor(Colors.seagreenColor, for: .normal)
                                            }
                                            
        }
        firestore.hasUserLikedOrDisliked(uid: Auth.auth().currentUser?.uid ?? "",
                                         funFactID: funFact.id,
                                         collection: "funFactsDisliked") { (hasDisliked, error) in
                                            if hasDisliked! {
                                                self.dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
                                                self.dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
                                                self.dislikeHeart.setTitleColor(Colors.redColor, for: .normal)
                                            }
                                            
        }
    }
    @objc func didPullToRefresh() {
        self.firestore.downloadUserProfile(Auth.auth().currentUser?.uid ?? "", completionHandler: { (userProfile, error) in
            if let error = error {
                print ("Error getting user profile \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.userProfile = userProfile!
                self.firestore.downloadFunFact(for: self.funFact.id, completionHandler: { (funFact, error) in
                    if let error = error {
                        print ("Error getting funFact on refresh \(error)")
                    } else {
                        self.funFact = funFact!
                        self.setupImage()
                        self.populatefunFactDesc()
                        self.setupVerifScreen()
                        self.setupImageCaption()
                        self.setupSubmittedBy()
                        self.setupSource()
                        self.setupDisputes()
                        self.setupLikesAndDislikes()
                        self.refreshControl?.endRefreshing()
                    }
                })
            }
        })
    }
    func populatefunFactDesc() {
        // Fun Fact title
        let funFactTitleAttrString = NSAttributedString(string: funFact.funFactTitle,
                                                        attributes: Attributes.attribute16DemiBlack)
        
        // Fun Fact description Text View
        let funFactDescAttr = NSMutableAttributedString(string: funFact.description)
        let attributedfunFactDesc = NSMutableAttributedString()
        
        funFactDescAttr.addAttributes(Attributes.attribute16RegularBlack,
                                      range: NSMakeRange(0, funFactDescAttr.length))
        if !funFact.tags.isEmpty {
            let staticTags = NSMutableAttributedString(string: "\nTags: ")
            staticTags.addAttributes(Attributes.attribute16RegularBlack,
                                     range: NSMakeRange(0, staticTags.length))
            
            let hashtags = "#" + funFact.tags.joined(separator: " #")
            let hashtagAttrString = NSMutableAttributedString(string: hashtags)
            hashtagAttrString.addAttributes(Attributes.attribute16DemiBlue,
                                            range: NSMakeRange(0, hashtagAttrString.length))
            
            funFactDescAttr.append(staticTags)
            funFactDescAttr.append(hashtagAttrString)
        }
        
        if funFact.funFactTitle.count > 1 {
            attributedfunFactDesc.append(funFactTitleAttrString)
            attributedfunFactDesc.append(NSAttributedString(string: "\n"))
        }
        attributedfunFactDesc.append(funFactDescAttr)
        funFactDescriptionTextView.attributedText = attributedfunFactDesc
        let hashtagGesture = UITapGestureRecognizer(target: self, action: #selector(hashtagTapAction))
        hashtagGesture.numberOfTapsRequired = 1
        funFactDescriptionTextView.addGestureRecognizer(hashtagGesture)
        funFactDescriptionTextView.isUserInteractionEnabled = true
    }
    func documentsDidUpdate() {
        
    }
    func setupImage() {
        let imageId = funFact.id
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            print("******In cache")
            self.landmarkImage.image = imageFromCache
        } else {
            let imageName = "\(funFact.id).jpeg"
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            gsReference.downloadURL { (url, error) in
                if let error = error {
                    print ("Error getting URL \(error)")
                } else {
                    self.landmarkImage.sd_setImage(with: url, placeholderImage: UIImage())
                }
            }
        }
    }
    
    func setupDisputeRejectedPage() {
        let rejView = UIView(frame: UIScreen.main.bounds)
        var displayString = ""
        rejView.tag = 101
        rejView.backgroundColor = UIColor(white: 0.9, alpha: 0.95)
        
        if funFact.verificationFlag == "R" {
            displayString = "This fact has been rejected by the community, it will be deleted after final review."
        }
        if funFact.disputeFlag == "Y" {
            displayString = "This fact is under dispute, awaiting final review by our team."
        }
        
        let rejTextLabel = UILabel()
        rejTextLabel.numberOfLines = 0
        rejTextLabel.textAlignment = NSTextAlignment.center
        let rejText = NSAttributedString(string: displayString, attributes: Attributes.attribute16DemiBlackAve)
        rejTextLabel.attributedText = rejText
        
        rejView.addSubview(rejTextLabel)
        self.view.addSubview(rejView)
        UIApplication.shared.keyWindow!.bringSubviewToFront(rejView)
        
        rejTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([rejTextLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                                     rejTextLabel.leftAnchor.constraint(equalTo: rejView.leftAnchor, constant: 10.0),
                                     rejTextLabel.rightAnchor.constraint(equalTo: rejView.rightAnchor, constant: -10.0)])
    }
    
    func setupVerificationPage() {
        let verifView = UIView(frame: UIScreen.main.bounds)
        verifView.tag = 100
        verifView.backgroundColor = UIColor(white: 0.9, alpha: 0.95)
        
        let verifTextLabel = UILabel()
        verifTextLabel.numberOfLines = 0
        verifTextLabel.textAlignment = NSTextAlignment.center
        let verifText = NSAttributedString(string: "This fact hasn't been verified yet. It will show up on this app only when it's verified by 3 people. You can help verify this fact by clicking below.", attributes: Attributes.attribute16DemiBlackAve)
        verifTextLabel.attributedText = verifText
        
        let verifButton = CustomButton()
        verifButton.frame = CGRect(x: 0, y: 0, width: verifView.frame.width - 20, height: 50)
        verifButton.layer.backgroundColor = Colors.seagreenColor.cgColor
        let verifButtonText = NSAttributedString(string: "Click To Verify", attributes: Attributes.loginButtonAttribute)
        verifButton.setAttributedTitle(verifButtonText, for: .normal)
        let verifButtonClickedText = NSAttributedString(string: "Click To Verify", attributes: Attributes.loginButtonClickedAttribute)
        verifButton.setAttributedTitle(verifButtonClickedText, for: .highlighted)
        verifButton.setAttributedTitle(verifButtonClickedText, for: .selected)
        verifButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        let approveButton = CustomButton()
        approveButton.frame = CGRect(x: 0, y: 0, width: verifView.frame.width - 20, height: 50)
        approveButton.layer.backgroundColor = Colors.seagreenColor.cgColor
        let approveButtonText = NSAttributedString(string: "Approve", attributes: Attributes.loginButtonAttribute)
        approveButton.setAttributedTitle(approveButtonText, for: .normal)
        let approveButtonClickedText = NSAttributedString(string: "Approve", attributes: Attributes.loginButtonClickedAttribute)
        approveButton.setAttributedTitle(approveButtonClickedText, for: .highlighted)
        approveButton.setAttributedTitle(approveButtonClickedText, for: .selected)
        approveButton.addTarget(self, action: #selector(approveAction), for: .touchUpInside)
        
        let rejectButton = CustomButton()
        rejectButton.frame = CGRect(x: 0, y: 0, width: verifView.frame.width - 20, height: 50)
        rejectButton.layer.backgroundColor = UIColor.white.cgColor
        rejectButton.layer.borderColor = Colors.seagreenColor.cgColor
        rejectButton.layer.borderWidth = 1.0
        rejectButton.tintColor = Colors.seagreenColor
        let rejectButtonText = NSAttributedString(string: "Reject", attributes: Attributes.cancelButtonAttribute)
        rejectButton.setAttributedTitle(rejectButtonText, for: .normal)
        let rejectButtonClickedText = NSAttributedString(string: "Reject", attributes: Attributes.cancelButtonClickedAttribute)
        rejectButton.setAttributedTitle(rejectButtonClickedText, for: .highlighted)
        rejectButton.setAttributedTitle(rejectButtonClickedText, for: .selected)
        rejectButton.addTarget(self, action: #selector(rejectAction), for: .touchUpInside)
        
        stack = UIStackView(frame: CGRect(x: 0, y: 0, width: verifView.frame.width - 20, height: 50))
        stack.addArrangedSubview(rejectButton)
        stack.addArrangedSubview(approveButton)
        stack.alignment = .center
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        
        self.view.addSubview(stack)
        verifView.addSubview(verifTextLabel)
        verifView.addSubview(verifButton)
        self.view.addSubview(verifView)
        UIApplication.shared.keyWindow!.bringSubviewToFront(verifView)

        verifTextLabel.translatesAutoresizingMaskIntoConstraints = false
        verifButton.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        approveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([verifTextLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                                     verifTextLabel.leftAnchor.constraint(equalTo: verifView.leftAnchor, constant: 10.0),
                                     verifTextLabel.rightAnchor.constraint(equalTo: verifView.rightAnchor, constant: -10.0),
                                     verifButton.heightAnchor.constraint(equalToConstant: 50.0),
                                     verifButton.leftAnchor.constraint(equalTo: verifView.leftAnchor, constant: 10.0),
                                     verifButton.rightAnchor.constraint(equalTo: verifView.rightAnchor, constant: -10.0),
                                     verifButton.topAnchor.constraint(equalTo: verifTextLabel.bottomAnchor, constant: 10.0),
                                     approveButton.heightAnchor.constraint(equalToConstant: 50.0),
                                     rejectButton.heightAnchor.constraint(equalToConstant: 50.0),
                                     stack.topAnchor.constraint(equalTo: submittedBy.bottomAnchor, constant: 20.0),
                                     stack.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10.0),
                                     stack.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10.0),
                                     stack.heightAnchor.constraint(equalToConstant: 50.0)])
    }
    @objc func dismissView(_ sender: UIButton) {
        self.view.viewWithTag(100)?.removeFromSuperview()
        quickHelpView = Utils.showQuickHelp()
        self.present(quickHelpView, animated: true, completion: nil)
    }
    /// Verify Action - Updates the approval count and user
    @objc func approveAction(_ sender: UIButton) {
        if Auth.auth().currentUser!.isAnonymous {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to verify a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        if funFact.submittedBy == Auth.auth().currentUser?.uid {
            let alert = UIAlertController(title: "Error",
                                          message: "You cannot verify this fact since you are the author. Please wait for others to verify this fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        for user in self.funFact.approvalUsers {
            if Auth.auth().currentUser?.uid == user {
                let alert = UIAlertController(title: "Error",
                                             message: "You have already verified this fact.",
                                             preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        let alertController = UIAlertController(title: "Verification",
                                                message: "Are you sure you want to verify? Before clicking ok please ensure that you have validated all the steps mentioned in the quick help.",
                                                preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            let apprCount = self.funFact.approvalCount + 1
            var verFlag = "N"
            if apprCount == 3 {
                verFlag = "Y"
            }
            self.firestore.updateVerificationFlag(
                for: self.funFact.id,
                verFlag: verFlag,
                apprCount: apprCount,
                completion: { (status) in
                    let status = status
                    var message = ""
                    if status == .success {
                        switch apprCount {
                        case 0..<3:
                            message = "Verification successful! We need \(3 - apprCount) more approvers to publish this fact on the app."
                        case 3:
                            message = "Great news! This fact has been verified."
                            self.navigationController?.popViewController(animated: true)
                        default:
                            message = "Verification successful! We need \(3 - apprCount) more approvers to publish this fact on the app."
                        }
                        
                        self.firestore.addFunFactVerifiedToUser(
                            funFact: self.funFact,
                            user: Auth.auth().currentUser?.uid ?? "") { (error) in
                                if let error = error {
                                    print ("Error updating user \(error)")
                                } else {
                                    self.firestore.downloadUserProfile(Auth.auth().currentUser?.uid ?? "", completionHandler: { (userProfile, error) in
                                        if let error = error {
                                            print ("Error getting user \(error)")
                                        } else {
                                            AppDataSingleton.appDataSharedInstance.userProfile = userProfile!
                                            self.didPullToRefresh()
                                        }
                                    })
                                    let alert = Utils.showAlert(status: status, message: message)
                                    self.present(alert, animated: true) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                            guard self?.presentedViewController == alert else { return }
                                            self?.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                        }
                    } else {
                        message = ErrorMessages.verificationError
                    }
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    /// Reject Action - Updates the rejection count and user
    @objc func rejectAction(_ sender: UIButton) {
        if Auth.auth().currentUser!.isAnonymous {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to reject a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        if funFact.submittedBy == Auth.auth().currentUser?.uid {
            let alert = UIAlertController(title: "Error",
                                          message: "You cannot reject this fact since you are the author. Please wait for others to verify this fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        for user in self.funFact.rejectionUsers {
            if Auth.auth().currentUser?.uid == user {
                let alert = UIAlertController(title: "Error",
                                              message: "You have already rejected this fact.",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.performSegue(withIdentifier: "verifySegue", sender: nil)
    }
    
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
    }
    @objc func disputeTapAction(sender : UITapGestureRecognizer) {
        if Auth.auth().currentUser!.isAnonymous {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to dispute a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        let text = (dispute.text)!
        let clickRange = (text as NSString).range(of: "Here")
        
        if sender.didTapAttributedTextInLabel(label: dispute, inRange: clickRange) {
            changeDisputeColor()
            performSegue(withIdentifier: "disputeViewDetail", sender: nil)
        }
    }
    @objc func hashtagTapAction(sender : UITapGestureRecognizer) {
        let location = sender.location(in: funFactDescriptionTextView)
        let position = CGPoint(x: location.x, y: location.y)
        let tapPosition = funFactDescriptionTextView.closestPosition(to: position)
        if tapPosition != nil {
            let textRange = funFactDescriptionTextView
                .tokenizer
                .rangeEnclosingPosition(tapPosition!,
                                        with: UITextGranularity.word,
                                        inDirection: UITextDirection(rawValue: 1))
            if textRange != nil {
                let tappedWord = funFactDescriptionTextView.text(in: textRange!)
                funFactDescriptionTextView.halfTextColorChange(fullText: funFactDescriptionTextView.text, changeText: tappedWord!)
                for tag in funFact.tags {
                    if tappedWord == tag {
                        firestore.getFunFacts(for: tappedWord!) { (funFacts, error) in
                            if let error = error {
                                print ("Error getting hashtag funfacts \(error)")
                            } else {
                                let funFactsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
                                funFactsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
                                funFactsVC.sender = .hashtags
                                funFactsVC.hashtagName = "#\(tappedWord!)"
                                self.navigationController?.pushViewController(funFactsVC, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func viewAddFactForLandmark(sender : UITapGestureRecognizer) {
        let addFactVC = AddNewFactViewController()
        if !(self.navigationController!.viewControllers.contains(addFactVC)){
            performSegue(withIdentifier: "addFactDetailForLandmark", sender: nil)
        }
    }
    
    @objc func viewImageViewer(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "imageSegue", sender: nil)
    }
    
    @objc func profileView(sender : UITapGestureRecognizer) {
        firestore.downloadUserProfile(funFact.submittedBy) { (user, error) in
            if let error = error {
                print ("Error getting user profile \(error)")
            } else {
                let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "profileView") as! ProfileViewController
                profileVC.uid = self.funFact.submittedBy
                profileVC.mode = .otherUser
                profileVC.userProfile = user!
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
    }
    
    func textView(_ sourceURL: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? DisputeViewController
        navigationController?.navigationBar.backItem?.title = ""
        destinationVC?.funFact = funFact
        
        let imageViewVC = segue.destination as? ImageViewViewController
        imageViewVC?.image = landmarkImage.image
        imageViewVC?.imageCaptionText = funFact.imageCaption

        let verifVC = segue.destination as? VerifyViewController
        verifVC?.callback = { (status) in
            if status == .success {
                self.didPullToRefresh()
            }
        }
        verifVC?.funFact = funFact
        verifVC?.rejectionCount = funFact.rejectionCount
        verifVC?.verFlag = funFact.verificationFlag
    }
    
    func editFunFact() {
        performSegue(withIdentifier: "addFactDetailForLandmark", sender: "edit")
    }
    
    func deleteFunFact() {
        
    }
    
    func changeDisputeColor() {
        let dispute1 = "See something wrong? Dispute this fact "
        let disAttrString1 = NSAttributedString(string: dispute1, attributes: Attributes.attribute12RegDG)
        
        let disputeArrow = String.fontAwesomeIcon(name: .arrowRight)
        let disputeArrowString = NSAttributedString(string: disputeArrow, attributes: Attributes.smallImageAttribute)
        
        let dispute2 = " Here"
        let disAttrString2 = NSAttributedString(string: dispute2, attributes: Attributes.attribute12Gray)
        
        let completeDispute = NSMutableAttributedString()
        completeDispute.append(disAttrString1)
        completeDispute.append(disputeArrowString)
        completeDispute.append(disAttrString2)
        
        dispute.attributedText = completeDispute
    }
}
extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
extension UITextView {
    func halfTextColorChange (fullText : String , changeText : String ) {
        
        let funFactDescAttr = NSMutableAttributedString(string: fullText)
        
        let regularSearchPattern = "\\w+"
        var regularRanges: [NSRange] = [NSRange]()
        let regularRegex = try! NSRegularExpression(pattern: regularSearchPattern, options: [])
        regularRanges = regularRegex.matches(in: funFactDescAttr.string,
                                             options: [],
                                             range: NSMakeRange(0, funFactDescAttr.string.count)).map {$0.range}
        
        for range in regularRanges {
            funFactDescAttr.addAttributes(Attributes.attribute16RegularBlack,
                                          range: NSRange(location: range.location,
                                                         length: range.length))
        }
        
        let hashtagSearchPattern = "#\\w+"
        var hashtagRanges: [NSRange] = [NSRange]()
        let hashtagRegex = try! NSRegularExpression(pattern: hashtagSearchPattern, options: [])
        hashtagRanges = hashtagRegex.matches(in: funFactDescAttr.string,
                                             options: [],
                                             range: NSMakeRange(0, funFactDescAttr.string.count)).map {$0.range}
        
        for range in hashtagRanges {
            funFactDescAttr.addAttributes(Attributes.attribute16DemiBlue,
                                          range: NSRange(location: range.location,
                                                         length: range.length))
        }
        
        let tappedSearchPattern = "#\\b\(changeText)\\b"
        var tappedRange = [NSRange]()
        let tappedRegex = try! NSRegularExpression(pattern: tappedSearchPattern, options: [])
        tappedRange = tappedRegex.matches(in: funFactDescAttr.string,
                                             options: [],
                                             range: NSMakeRange(0, funFactDescAttr.string.count)).map {$0.range}
        
        for range in tappedRange {
            funFactDescAttr.addAttributes(Attributes.attribute16Gray,
                                          range: NSRange(location: range.location,
                                                         length: range.length))
        }
        let attributedfunFactDesc = NSMutableAttributedString()
        attributedfunFactDesc.append(funFactDescAttr)
        
        self.attributedText = attributedfunFactDesc
    }
}
