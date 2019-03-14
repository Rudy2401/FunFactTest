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

class ContentViewController: UIViewController, FirestoreManagerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var funFactDescriptionTextView: UITextView!
    @IBOutlet var landmarkImage: UIImageView!
    @IBOutlet var submittedBy: UILabel!
    @IBOutlet var likeHeart: UIButton!
    @IBOutlet var dislikeHeart: UIButton!
    @IBOutlet var sourceURL: UITextView!
    @IBOutlet weak var dispute: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var dislikeCount: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageCaptionLabel: UILabel!
    
    let util = Utils()
    var dataObject: AnyObject?
    var imageObject: AnyObject?
    var imageCaption = ""
    var landmarkID = ""
    var submittedByObject: AnyObject?
    var sourceObject: AnyObject?
    var likesObject: AnyObject?
    var dislikesObject: AnyObject?
    var headingObject: AnyObject?
    var dateObject: AnyObject?
    var funFactID: String = ""
    var funFactDesc: String = ""
    var address: String = ""
    var verifiedFlag: String = ""
    var disputeFlag: String = ""
    var tags: [String] = [""]
    var currPageNumberText = ""
    var totalPageNumberText = ""
    var approvalCount = 0
    var rejectionCount = 0
    var approvalUsers = [String]()
    var rejectionUsers = [String]()
    var rejectionReason = [String]()
    var quickHelpView = UIAlertController()
    var popup = UIAlertController()
    var firestore = FirestoreManager()
    
    @IBAction func likeIt(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to like/dislike a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.lightGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: Colors.redColor) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(Colors.seagreenColor, for: .normal)
            
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(.lightGray, for: .normal)
            firestore.addLikes(funFactID: funFactID, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
            firestore.deleteDislikes(funFactID: funFactID, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.lightGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.lightGray) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(Colors.seagreenColor, for: .normal)
            firestore.addLikes(funFactID: funFactID, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
            
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: Colors.seagreenColor)
            && Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.lightGray) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(.lightGray, for: .normal)
            firestore.deleteLikes(funFactID: funFactID, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        }
    }
    
    @IBAction func dislikeIt(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to like/dislike a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.lightGray)
            &&  Utils.compareColors(c1: likeHeart.currentTitleColor, c2: Colors.seagreenColor) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(.lightGray, for: .normal)
            
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(Colors.redColor, for: .normal)
            firestore.addDislikes(funFactID: funFactID, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
            firestore.deleteLikes(funFactID: funFactID, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.lightGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.lightGray) {
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(Colors.redColor, for: .normal)
            firestore.addDislikes(funFactID: funFactID, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: Colors.redColor)
            && Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.lightGray) {
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(.lightGray, for: .normal)
            firestore.deleteDislikes(funFactID: funFactID, landmarkID: landmarkID, userID: Auth.auth().currentUser?.uid ?? "")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceURL.isScrollEnabled = false
        funFactDescriptionTextView.delegate = self
        if verifiedFlag == "N" {
            setupVerificationPage()
        }
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            if #available(iOS 11.0, *) {
                navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: customFont ]
            } else {
                // Fallback on earlier versions
            }
        }
        if (self.navigationController?.presentingViewController as? FunFactPageViewController) != nil {
            let addFactGesture = UITapGestureRecognizer(target: self, action: #selector(viewAddFactForLandmark))
            addFactGesture.numberOfTapsRequired = 1
            let button = navigationController?.toolbar.items?[2].customView as! UIButton // swiftlint:disable:this force_cast
            button.addGestureRecognizer(addFactGesture)
        } else {
            navigationItem.title = headingObject as? String
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if verifiedFlag == "N" {
            likeHeart.isHidden = true
            dislikeHeart.isHidden = true
            likeCount.isHidden = true
            dislikeCount.isHidden = true
            dispute.isHidden = true
        }
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.height)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: self.view.frame.height)
        
        pageNumber.text = "Fact (\(currPageNumberText)/\(totalPageNumberText))"
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(viewImageViewer))
        imageGesture.numberOfTapsRequired = 1
        landmarkImage.isUserInteractionEnabled = true
        landmarkImage.addGestureRecognizer(imageGesture)
        
        imageCaptionLabel.text = imageCaption
        
        firestore.downloadUserProfile(submittedByObject as! String) { (userProfile) in
            let submittedBy1 = "Submitted By: "
            let myAttrString1 = NSAttributedString(string: submittedBy1, attributes: Attributes.attribute12BoldDG)
            let completeSubmittedBy = NSMutableAttributedString()
            let userID = userProfile.userName
            let submittedBy2 = userID
            let myAttrString2 = NSAttributedString(string: submittedBy2, attributes: Attributes.attribute12RegBlue)
            let profileGesture = UITapGestureRecognizer(target: self, action: #selector(self.profileView))
            profileGesture.numberOfTapsRequired = 1
            
            self.submittedBy.isUserInteractionEnabled = true
            self.submittedBy.addGestureRecognizer(profileGesture)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let date = self.dateObject as! Timestamp
            let date1 = dateFormatter.string(from: date.dateValue())
            let myAttrString3 = NSAttributedString(string: ", \(date1)", attributes: Attributes.attribute10RegDG)
            
            completeSubmittedBy.append(myAttrString1)
            completeSubmittedBy.append(myAttrString2)
            completeSubmittedBy.append(myAttrString3)
            self.submittedBy.frame.size = self.submittedBy.intrinsicContentSize
            self.submittedBy.attributedText = completeSubmittedBy
        }
        
        
        let source1 = "Source: "
        let sourceAtt1 = NSMutableAttributedString(string: source1)
        sourceAtt1.addAttributes(Attributes.attribute12BoldDG, range: (source1 as NSString).range(of: source1))
        let source2 = sourceObject as! String
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
        
        // Fun Fact description Text View
        funFactDescriptionTextView.layer.borderWidth = 0
        funFactDescriptionTextView.layer.borderColor = UIColor.black.cgColor
        funFactDescriptionTextView.isEditable = false
        funFactDescriptionTextView.isScrollEnabled = false
        
        let funFactDescAttr = NSMutableAttributedString(string: funFactDesc)
        
        let regularSearchPattern = "\\w+"
        var regularRanges: [NSRange] = [NSRange]()
        let regularRegex = try! NSRegularExpression(pattern: regularSearchPattern, options: [])
        regularRanges = regularRegex.matches(in: funFactDescAttr.string,
                                             options: [],
                                             range: NSMakeRange(0, funFactDescAttr.string.count)).map {$0.range}
        
        for range in regularRanges {
            funFactDescAttr.addAttributes(Attributes.attribute16DemiBlack,
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
        let attributedFunFactDesc = NSMutableAttributedString()
        attributedFunFactDesc.append(funFactDescAttr)
        
        funFactDescriptionTextView.attributedText = attributedFunFactDesc
        let hashtagGesture = UITapGestureRecognizer(target: self, action: #selector(hashtagTapAction))
        hashtagGesture.numberOfTapsRequired = 1
        funFactDescriptionTextView.addGestureRecognizer(hashtagGesture)
        funFactDescriptionTextView.isUserInteractionEnabled = true
        
        setupImage()
        sourceURL.attributedText = attributedString
        likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
        likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
        likeCount.text = "\(likesObject as! Int)" + " likes"
        dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
        dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
        dislikeCount.text = "\(dislikesObject as! Int)" + " dislikes"
        sourceURL.isEditable = false
        sourceURL.dataDetectorTypes = .link
        sourceURL.textContainerInset = UIEdgeInsets.zero
        sourceURL.textContainer.lineFragmentPadding = 0
        sourceURL.textAlignment = .center
        let disAttribute = [ NSAttributedString.Key.foregroundColor: Colors.blueColor,
                             NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 12.0)!] as [NSAttributedString.Key: Any]
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
        
        for id in (AppDataSingleton.appDataSharedInstance.userProfile.funFactsLiked) {
            if id.documentID == funFactID {
                likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
                likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
                likeHeart.setTitleColor(Colors.seagreenColor, for: .normal)
            }
        }
        for id in (AppDataSingleton.appDataSharedInstance.userProfile.funFactsDisliked) {
            if id.documentID == funFactID {
                dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
                dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
                dislikeHeart.setTitleColor(Colors.redColor, for: .normal)
            }
        }
        
    }
    func documentsDidUpdate() {
        
    }
    func setupImage() {
        let imageId = funFactID
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            print("******In cache")
            self.landmarkImage.image = imageFromCache
            self.landmarkImage.layer.cornerRadius = 5
        } else {
            let imageName = "\(funFactID).jpeg"
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            self.landmarkImage.sd_setImage(with: gsReference, placeholderImage: UIImage())
            self.landmarkImage.layer.cornerRadius = 5
        }
    }
    
    func setupVerificationPage() {
        let verifView = UIView(frame: UIScreen.main.bounds)
        verifView.tag = 100
        verifView.backgroundColor = UIColor(white: 0.9, alpha: 0.95)
        
        let verifTextLabel = UILabel()
        verifTextLabel.numberOfLines = 0
        verifTextLabel.textAlignment = NSTextAlignment.center
        let verifText = NSAttributedString(string: "This fact hasn't been verified yet. It will show up on this app only when it's verified by 3 people. You can help verify this fact by clicking below.", attributes: Attributes.attribute16DemiBlack)
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
        
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: verifView.frame.width - 20, height: 50))
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
        NSLayoutConstraint.activate([verifTextLabel.centerYAnchor.constraint(equalTo: verifView.centerYAnchor),
                                     verifTextLabel.leftAnchor.constraint(equalTo: verifView.leftAnchor, constant: 10.0),
                                     verifTextLabel.rightAnchor.constraint(equalTo: verifView.rightAnchor, constant: -10.0),
                                     verifButton.heightAnchor.constraint(equalToConstant: 50.0),
                                     verifButton.leftAnchor.constraint(equalTo: verifView.leftAnchor, constant: 10.0),
                                     verifButton.rightAnchor.constraint(equalTo: verifView.rightAnchor, constant: -10.0),
                                     verifButton.topAnchor.constraint(equalTo: verifTextLabel.bottomAnchor, constant: 10.0),
                                     approveButton.heightAnchor.constraint(equalToConstant: 50.0),
                                     rejectButton.heightAnchor.constraint(equalToConstant: 50.0),
                                     stack.topAnchor.constraint(equalTo: dispute.bottomAnchor, constant: 20.0),
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
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to verify a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        if submittedByObject as? String == Auth.auth().currentUser?.uid {
            let alert = UIAlertController(title: "Error",
                                          message: "You cannot verify this fact since you are the author. Please wait for others to verify this fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        for user in self.approvalUsers {
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
            let db = Firestore.firestore()
            let funFactRef = db.collection("funFacts").document(self.funFactID)
            let apprCount = self.approvalCount + 1
            var verFlag = "N"
            if apprCount == 3 {
                verFlag = "Y"
            }
            self.firestore.updateVerificationFlag(
                for: self.funFactID,
                verFlag: verFlag,
                apprCount: apprCount,
                completion: { (status) in
                    self.showAlert(message: status, count: apprCount)
                })
            self.firestore.addFunFactVerifiedToUser(
                funFactRef: funFactRef,
                funFactID: self.funFactID,
                user: Auth.auth().currentUser?.uid ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    /// Reject Action - Updates the rejection count and user
    @objc func rejectAction(_ sender: UIButton) {
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Error",
                                          message: "Please sign in to reject a fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        if submittedByObject as? String == Auth.auth().currentUser?.uid {
            let alert = UIAlertController(title: "Error",
                                          message: "You cannot reject this fact since you are the author. Please wait for others to verify this fact.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        for user in self.rejectionUsers {
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
    func showAlert(message: String, count: Int) {
        if message == "success" {
            popup = UIAlertController(title: "Success",
                                      message: "Verification successful! We need \(3 - count) more approvers to publish this fact on the app.",
                                      preferredStyle: .alert)
        }
        if message == "fail" {
            popup = UIAlertController(title: "Error",
                                      message: "Error while verifying.",
                                      preferredStyle: .alert)
        }
        
        self.present(popup, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 2.0,
                             target: self,
                             selector: #selector(self.dismissAlert),
                             userInfo: nil,
                             repeats: false)
    }
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
    }
    @objc func disputeTapAction(sender : UITapGestureRecognizer) {
        if Auth.auth().currentUser == nil {
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
                for tag in tags {
                    if tappedWord == tag {
                        firestore.getFunFacts(for: tappedWord!) { (refs, error) in
                            if let error = error {
                                print ("Error getting hashtag funfacts \(error)")
                            } else {
                                let funFactsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
                                funFactsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
                                funFactsVC.refs = refs
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
        firestore.downloadUserProfile(submittedByObject as! String) { (user) in
            let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "profileView") as! ProfileViewController
            profileVC.uid = self.submittedByObject as! String
            profileVC.mode = "other"
            profileVC.userProfile = user
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func textView(_ sourceURL: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? DisputeViewController
        navigationController?.navigationBar.backItem?.title = ""
        destinationVC?.funFactID = funFactID
        
        let imageViewVC = segue.destination as? ImageViewViewController
        imageViewVC?.image = landmarkImage.image
        imageViewVC?.imageCaptionText = imageCaption

        let verifVC = segue.destination as? VerifyViewController
        verifVC?.funFactID = funFactID
        verifVC?.rejectionCount = rejectionCount
        verifVC?.verFlag = verifiedFlag
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
            funFactDescAttr.addAttributes(Attributes.attribute16DemiBlack,
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
        let attributedFunFactDesc = NSMutableAttributedString()
        attributedFunFactDesc.append(funFactDescAttr)
        
        self.attributedText = attributedFunFactDesc
    }
}
