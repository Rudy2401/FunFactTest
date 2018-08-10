//
//  ContentViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/27/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FontAwesome_swift
import Firebase
import FirebaseStorage

class ContentViewController: UIViewController {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var landmarkImage: UIImageView!
    @IBOutlet var submittedBy: UILabel!
    @IBOutlet var likes: UILabel!
    @IBOutlet var likeHeart: UIButton!
    @IBOutlet var dislikeHeart: UIButton!
    @IBOutlet var sourceURL: UITextView!
    @IBOutlet weak var dispute: UILabel!
    
    
    let util = Utils()
    var dataObject: AnyObject?
    var imageObject: AnyObject?
    var submittedByObject: AnyObject?
    var sourceObject: AnyObject?
    var likesObject: AnyObject?
    var headingObject: AnyObject?
    var dateObject: AnyObject?
    var funFactID: String = ""
    var address: String = ""
    
    @IBAction func likeIt(_ sender: Any) {
//        if (likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsOUp) &&  dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsDown))
//        || (likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsOUp) &&  dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsODown)) {
//            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
//            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsODown), for: .normal)
//        } else if (likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsUp) &&  dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsODown)) {
//            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsOUp), for: .normal)
//        }
        
    }
    
    @IBAction func dislikeIt(_ sender: Any) {
//        if (dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsODown) &&  likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsUp))
//        || (likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsOUp) &&  dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsODown)) {
//            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
//            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsOUp), for: .normal)
//        } else if (dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsDown) && likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsOUp)) {
//            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsODown), for: .normal)
//        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        let button = navigationController?.toolbar.items?[2].customView as! UIButton
        button.addTarget(self, action: #selector(viewAddFactForLandmark), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let submittedBy1 = "Submitted By: "
        let myAttribute1 = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                            NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 12.0)!
        ]
        let myAttrString1 = NSAttributedString(string: submittedBy1, attributes: myAttribute1)
        
        let myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                             NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 12.0)!
        ]
        
        let submittedBy2 = submittedByObject as? String
        let myAttrString2 = NSAttributedString(string: submittedBy2!, attributes: myAttribute1)
        
        let date1 = ", " + (dateObject as! String)
        let myAttribute3 = [ NSAttributedStringKey.foregroundColor: UIColor.gray,
                             NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 10.0)!
        ]
        let myAttrString3 = NSAttributedString(string: date1, attributes: myAttribute3)
        
        let completeSubmittedBy = NSMutableAttributedString()
        completeSubmittedBy.append(myAttrString1)
        completeSubmittedBy.append(myAttrString2)
        completeSubmittedBy.append(myAttrString3)
        
        let source1 = "Source: "
        let sourceAtt1 = NSMutableAttributedString(string: source1)
        sourceAtt1.addAttributes(myAttribute1, range: (source1 as NSString).range(of: source1))
        
        let source2 = sourceObject as! String
        var substring = ""
        if source2.count > 40 {
            let index = source2.index(source2.startIndex, offsetBy: 40)
            substring = source2[...index] + "..."
        }
        else {
            substring = source2
        }
        let sourceAtt2 = NSMutableAttributedString(string: substring)
        sourceAtt2.addAttributes(myAttribute2, range: (substring as NSString).range(of: substring))
        sourceAtt2.addAttribute(.link, value: source2, range: NSRange(location: 0, length: substring.count))
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(sourceAtt1)
        attributedString.append(sourceAtt2)
        
        submittedBy.frame.size = submittedBy.intrinsicContentSize
        textLabel.text = dataObject as? String
        
        var image = UIImage()
        let s = funFactID
        let imageName = "\(s).jpeg"
        
        let storage = Storage.storage()
        let gsReference = storage.reference(forURL: "gs://funfacts-5b1a9.appspot.com/images/\(imageName)")
        
        gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error = \(error)")
            } else {
                image = UIImage(data: data!)!
                self.landmarkImage.image = image
                self.landmarkImage.layer.cornerRadius = 5
            }
        }
        
//        landmarkImage.image = UIImage(named: imageObject as! String)
        submittedBy.attributedText = completeSubmittedBy
        sourceURL.attributedText = attributedString
        likes.text = likesObject as? String
        
        likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
        dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
        sourceURL.isEditable = false
        sourceURL.dataDetectorTypes = .link
        sourceURL.textContainerInset = UIEdgeInsets.zero
        sourceURL.textContainer.lineFragmentPadding = 0
        sourceURL.textAlignment = .center
        
        let disAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(displayP3Red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0),
                             NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 12.0)!,
                             NSAttributedStringKey.underlineStyle: NSUnderlineStyle.patternSolid.rawValue] as [NSAttributedStringKey : Any]
        let dispute1 = "See something wrong? Dispute this fact --> "
        let disAttrString1 = NSAttributedString(string: dispute1, attributes: myAttribute2)
        
        let dispute2 = "Here"
        let disAttrString2 = NSAttributedString(string: dispute2, attributes: disAttribute)
        
        let completeDispute = NSMutableAttributedString()
        completeDispute.append(disAttrString1)
        completeDispute.append(disAttrString2)
        
        dispute.attributedText = completeDispute
        let disputeGesture = UITapGestureRecognizer(target: self, action: #selector(disputeTapAction))
        disputeGesture.numberOfTapsRequired = 1
        dispute.addGestureRecognizer(disputeGesture)
        dispute.isUserInteractionEnabled = true
        
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
    @objc func viewAddFactForLandmark() {
        print("In viewAddFactForLandmark")
        performSegue(withIdentifier: "addFactDetailForLandmark", sender: nil)
    }
    
    func textView(_ sourceURL: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? DisputeViewController
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        destinationVC?.funFactID = funFactID
        
        let addFactVC = segue.destination as? AddFactViewController
        addFactVC?.address = address
        addFactVC?.landmarkName = headingObject as! String
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
        attribute.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.lightGray , range: range)
        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(displayP3Red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0) , range: range)
        attribute.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Avenir Next", size: 12.0)! , range: range)
        self.attributedText = attribute
    }
}
