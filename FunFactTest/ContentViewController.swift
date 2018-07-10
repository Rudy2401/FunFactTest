//
//  ContentViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/27/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FontAwesome_swift

class ContentViewController: UIViewController {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var landmarkImage: UIImageView!
    @IBOutlet var submittedBy: UILabel!
    @IBOutlet var likes: UILabel!
    @IBOutlet var heading: UILabel!
    @IBOutlet var pageNumber: UILabel!
    @IBOutlet var likeHeart: UIButton!
    @IBOutlet var dislikeHeart: UIButton!
    @IBOutlet var sourceURL: UITextView!
    
    
    let util = Utils()
    var dataObject: AnyObject?
    var imageObject: AnyObject?
    var submittedByObject: AnyObject?
    var sourceObject: AnyObject?
    var likesObject: AnyObject?
    var headingObject: AnyObject?
    var pageNumberObject: AnyObject?
    var dateObject: AnyObject?
    
    @IBAction func likeIt(_ sender: Any) {
        if (likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsOUp) &&  dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsDown))
        || (likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsOUp) &&  dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsODown)) {
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsUp), for: .normal)
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsODown), for: .normal)
        } else if (likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsUp) &&  dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsODown)) {
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsOUp), for: .normal)
        }
    }
    
    @IBAction func dislikeIt(_ sender: Any) {
        if (dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsODown) &&  likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsUp))
        || (likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsOUp) &&  dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsODown)) {
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsDown), for: .normal)
            likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsOUp), for: .normal)
        } else if (dislikeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsDown) && likeHeart.currentTitle == String.fontAwesomeIcon(name: .thumbsOUp)) {
            dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsODown), for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("In viewWillAppear")
        
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
        landmarkImage.image = UIImage(named: imageObject as! String)
        submittedBy.attributedText = completeSubmittedBy
        sourceURL.attributedText = attributedString
        likes.text = likesObject as? String
        heading.text = headingObject as? String
        pageNumber.text = pageNumberObject as? String
        
        likeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        likeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsOUp), for: .normal)
        dislikeHeart.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        dislikeHeart.setTitle(String.fontAwesomeIcon(name: .thumbsODown), for: .normal)
        sourceURL.isEditable = false
        sourceURL.dataDetectorTypes = .link
        sourceURL.textContainerInset = UIEdgeInsets.zero
        sourceURL.textContainer.lineFragmentPadding = 0
        sourceURL.textAlignment = .center
    }
    func textView(_ sourceURL: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
