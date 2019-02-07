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

class ContentViewController: UIViewController {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var landmarkImage: UIImageView!
    @IBOutlet var submittedBy: UILabel!
    @IBOutlet var likeHeart: UIButton!
    @IBOutlet var dislikeHeart: UIButton!
    @IBOutlet var sourceURL: UITextView!
    @IBOutlet weak var dispute: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var dislikeCount: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    
    let util = Utils()
    var dataObject: AnyObject?
    var imageObject: AnyObject?
    var imageCaption = ""
    var landmarkType = ""
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
    
    @IBAction func likeIt(_ sender: Any) {
        if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.lightGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: Colors.redColor) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(Colors.seagreenColor, for: .normal)
            
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(.lightGray, for: .normal)
            addLikes(funFactID: funFactID, userID: Auth.auth().currentUser?.uid ?? "")
            deleteDislikes(funFactID: funFactID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.lightGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.lightGray) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(Colors.seagreenColor, for: .normal)
            addLikes(funFactID: funFactID, userID: Auth.auth().currentUser?.uid ?? "")
            
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: Colors.seagreenColor)
            && Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.lightGray) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(.lightGray, for: .normal)
            deleteLikes(funFactID: funFactID, userID: Auth.auth().currentUser?.uid ?? "")
        }
    }
    
    @IBAction func dislikeIt(_ sender: Any) {
        if Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.lightGray)
            &&  Utils.compareColors(c1: likeHeart.currentTitleColor, c2: Colors.seagreenColor) {
            likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            likeHeart.setTitleColor(.lightGray, for: .normal)
            
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(Colors.redColor, for: .normal)
            addDislikes(funFactID: funFactID, userID: Auth.auth().currentUser?.uid ?? "")
            deleteLikes(funFactID: funFactID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.lightGray)
            &&  Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: UIColor.lightGray) {
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(Colors.redColor, for: .normal)
            addDislikes(funFactID: funFactID, userID: Auth.auth().currentUser?.uid ?? "")
        } else if Utils.compareColors(c1: dislikeHeart.currentTitleColor, c2: Colors.redColor)
            && Utils.compareColors(c1: likeHeart.currentTitleColor, c2: UIColor.lightGray) {
            dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            dislikeHeart.setTitleColor(.lightGray, for: .normal)
            deleteDislikes(funFactID: funFactID, userID: Auth.auth().currentUser?.uid ?? "")
        }
    }
    func addLikes(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                // swiftlint:disable:next force_cast
                let likeCount = document.data()?["likes"] as! Int
                funFactRef.setData([
                    "likes": likeCount + 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error)")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                // swiftlint:disable:next force_cast
                let likeCount = document.data()?["likes"] as! Int
                db.collection("landmarks").document(self.landmarkID).setData([
                    "likes": likeCount + 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error.debugDescription)")
            }
        }
        db.collection("users").document(userID).collection("funFactsLiked").document(funFactID).setData([
            "funFactID": funFactRef
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    func addDislikes(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                funFactRef.setData([
                    "dislikes": dislikeCount + 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error)")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                db.collection("landmarks").document(self.landmarkID).setData([
                    "dislikes": dislikeCount + 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error.debugDescription)")
            }
        }
        db.collection("users").document(userID).collection("funFactsDisliked").document(funFactID).setData([
            "funFactID": funFactRef
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    func deleteLikes(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                let likeCount = document.data()?["likes"] as! Int // swiftlint:disable:this force_cast
                funFactRef.setData([
                    "likes": likeCount - 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error)")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["likes"] as! Int // swiftlint:disable:this force_cast
                db.collection("landmarks").document(self.landmarkID).setData([
                    "likes": dislikeCount - 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error.debugDescription)")
            }
        }
        db.collection("users").document(userID).collection("funFactsLiked").document(funFactID).delete()
    }
    func deleteDislikes(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        funFactRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                funFactRef.setData([
                    "dislikes": dislikeCount - 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error)")
            }
        }
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                let dislikeCount = document.data()?["dislikes"] as! Int // swiftlint:disable:this force_cast
                db.collection("landmarks").document(self.landmarkID).setData([
                    "dislikes": dislikeCount - 1
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                print ("Error getting document \(error.debugDescription)")
            }
        }
        db.collection("users").document(userID).collection("funFactsDisliked").document(funFactID).delete()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if Auth.auth().currentUser == nil {
            likeHeart.isEnabled = false
            dislikeHeart.isEnabled = false
        } else {
            likeHeart.isEnabled = true
            dislikeHeart.isEnabled = true
        }
        pageNumber.text = "Fact (\(currPageNumberText)/\(totalPageNumberText))"
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(viewImageViewer))
        imageGesture.numberOfTapsRequired = 1
        landmarkImage.isUserInteractionEnabled = true
        landmarkImage.addGestureRecognizer(imageGesture)
        let submittedBy1 = "Submitted By: "
        let myAttrString1 = NSAttributedString(string: submittedBy1, attributes: Attributes.attribute12BoldDG)
        let completeSubmittedBy = NSMutableAttributedString()
        let userID: String = AppDataSingleton.appDataSharedInstance.usersDict[submittedByObject as! String]?.email ?? "" // swiftlint:disable:this force_cast
        let submittedBy2 = userID.components(separatedBy: "@").first
        let myAttrString2 = NSAttributedString(string: submittedBy2 ?? "", attributes: Attributes.attribute12RegBlue)
        let profileGesture = UITapGestureRecognizer(target: self, action: #selector(profileView))
        profileGesture.numberOfTapsRequired = 1
        submittedBy.isUserInteractionEnabled = true
        submittedBy.addGestureRecognizer(profileGesture)
        let date1 = ", " + (self.dateObject as! String) // swiftlint:disable:this force_cast
        let myAttrString3 = NSAttributedString(string: date1, attributes: Attributes.attribute10RegDG)
        completeSubmittedBy.append(myAttrString1)
        completeSubmittedBy.append(myAttrString2)
        completeSubmittedBy.append(myAttrString3)
        self.submittedBy.frame.size = self.submittedBy.intrinsicContentSize
        self.submittedBy.attributedText = completeSubmittedBy
        let source1 = "Source: "
        let sourceAtt1 = NSMutableAttributedString(string: source1)
        sourceAtt1.addAttributes(Attributes.attribute12BoldDG, range: (source1 as NSString).range(of: source1))
        let source2 = sourceObject as! String // swiftlint:disable:this force_cast
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
        let funFactDescAttr = NSMutableAttributedString(string: funFactDesc)
        let unverifiedAttr = NSMutableAttributedString(string: " (This fact needs verification)",
                                                       attributes: Attributes.attribute14ItalicsDG)
        let searchPattern = "#\\w+"
        var ranges: [NSRange] = [NSRange]()
        let regex = try! NSRegularExpression(pattern: searchPattern, options: [])
        ranges = regex.matches(in: funFactDescAttr.string,
                               options: [],
                               range: NSMakeRange(0, funFactDescAttr.string.count)).map {$0.range}
        for range in ranges {
            funFactDescAttr.addAttributes(Attributes.attribute14DemiBlue,
                                          range: NSRange(location: range.location,
                                                         length: range.length))
        }
        let attributedFunFactDesc = NSMutableAttributedString()
        attributedFunFactDesc.append(funFactDescAttr)
        //        if verifiedFlag == "N" {
        //            attributedFunFactDesc.append(unverifiedAttr)
        //        }
        textLabel.attributedText = attributedFunFactDesc
        setupImage()
        sourceURL.attributedText = attributedString
        likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
        likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
        likeCount.text = "\(likesObject as! Int)" + " likes" // swiftlint:disable:this force_cast
        dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .light)
        dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
        dislikeCount.text = "\(dislikesObject as! Int)" + " dislikes" // swiftlint:disable:this force_cast
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
    @objc func disputeTapAction(sender : UITapGestureRecognizer) {
        
        let text = (dispute.text)!
        let clickRange = (text as NSString).range(of: "Here")
        
        if sender.didTapAttributedTextInLabel(label: dispute, inRange: clickRange) {
            dispute.halfTextColorChange(fullText: dispute.text!, changeText: "Here")
            performSegue(withIdentifier: "disputeViewDetail", sender: nil)
        }
        else {
            
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
        performSegue(withIdentifier: "profileSegue", sender: nil)
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
        
        let profileVC = segue.destination as? ProfileViewController
        profileVC?.uid = AppDataSingleton.appDataSharedInstance.usersDict[submittedByObject as! String]?.uid ?? ""
        profileVC?.mode = "other"
    }
    
    func editFunFact() {
        performSegue(withIdentifier: "addFactDetailForLandmark", sender: "edit")
    }
    
    func deleteFunFact() {
        
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
extension UILabel {
    func halfTextColorChange (fullText : String , changeText : String ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.lightGray , range: range)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.blueColor , range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Avenir Next", size: 12.0)! , range: range)
        self.attributedText = attribute
    }
}
