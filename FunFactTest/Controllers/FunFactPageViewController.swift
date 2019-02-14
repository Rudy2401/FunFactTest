//
//  FunFactPageViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/27/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FacebookShare
import FirebaseStorage

class FunFactPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var imageContent = NSArray()
    var submittedByContent = NSArray()
    var sourceContent = NSArray()
    var likesContent = NSArray()
    var headingContent: String = ""
    var landmarkID: String = ""
    var address: String = ""
    var dateContent = NSArray()
    var currentIndex = 0
    var totalPages = 0
    var landmarkType = ""
    var funFacts = [FunFact]()
    var funFactDict = [String: [FunFact]]()
    var currentVC = ContentViewController()
    var synth = AVSpeechSynthesizer()
    var pageContent = NSArray()
    let pageControl = UIPageControl()
    var quickHelpView = UIAlertController()
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if (currentIndex == 0) || (currentIndex == NSNotFound) {
            return nil
        }
        return viewControllerAtIndex(currentIndex-1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print (totalPages)
        if currentIndex == NSNotFound {
            return nil
        }
        if currentIndex+1 == totalPages {
            return nil
        }
        return viewControllerAtIndex(currentIndex+1)
    }
    
    required init?(coder aDecoder: NSCoder) {
//        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.totalPages = pageContent.count
        self.view.backgroundColor = .white
        setupPageControl()
        
        setupToolbarAndNavigationbar()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .darkGray
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        self.setViewControllers([viewControllerAtIndex(0)] as? [UIViewController], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers?.last
        self.pageControl.currentPage = pageContent.index(of: pageContentViewController!)
        
        if (!completed && currentIndex==0) {
            
        }
        if (completed && finished) {
            if let currentVC = pageViewController.viewControllers?.last {
                currentIndex = indexOfViewController(viewController: currentVC as! ContentViewController)
                print ("currentIndex = \(currentIndex)")
                self.pageControl.currentPage = currentIndex
            }
        }
    }

    
    func viewControllerAtIndex(_ index: Int) -> ContentViewController? {
        if (funFacts.count == 0) || (index >= funFacts.count) {
            return nil
        }
        
        let dataViewController = self.storyboard?.instantiateViewController(withIdentifier: "contentView") as! ContentViewController
        navigationItem.title = headingContent
        dataViewController.dataObject = funFacts[index].id as AnyObject
        dataViewController.funFactDesc = funFacts[index].description as String
        dataViewController.imageObject = funFacts[index].image as AnyObject
        dataViewController.submittedByObject = funFacts[index].submittedBy as AnyObject
        dataViewController.dateObject = funFacts[index].dateSubmitted as AnyObject
        dataViewController.sourceObject = funFacts[index].source as AnyObject
        dataViewController.verifiedFlag = funFacts[index].verificationFlag
        dataViewController.disputeFlag = funFacts[index].disputeFlag
        dataViewController.imageCaption = funFacts[index].imageCaption
        dataViewController.tags = funFacts[index].tags
        dataViewController.likesObject = funFacts[index].likes as AnyObject
        dataViewController.dislikesObject = funFacts[index].dislikes as AnyObject
        dataViewController.funFactID = funFacts[index].id
        dataViewController.address = address
        dataViewController.headingObject = headingContent as AnyObject
        dataViewController.landmarkType = landmarkType
        dataViewController.landmarkID = landmarkID
        dataViewController.currPageNumberText = String(index+1)
        dataViewController.totalPageNumberText = String(totalPages)
        currentVC = dataViewController
        return dataViewController
    }
    
    func indexOfViewController(viewController: ContentViewController) -> Int {
        if let dataObject: AnyObject = viewController.dataObject {
            return pageContent.index(of: dataObject)
        } else {
            return NSNotFound
        }
    }
    
    func setupToolbarAndNavigationbar () {
        let toolBarAttrImage = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                 NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .solid)]
        let toolBarAttrLabel = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                 NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
        
        let toolBarAttrImageClicked = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
                                 NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 30, style: .solid)]
        let toolBarAttrLabelClicked = [ NSAttributedString.Key.foregroundColor: Colors.seagreenColor,
                                 NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let prevLabel1 = String.fontAwesomeIcon(name: .arrowLeft)
        let prevLabelAttr1 = NSAttributedString(string: prevLabel1, attributes: toolBarAttrImage)
        let prevLabelAttrClicked1 = NSAttributedString(string: prevLabel1, attributes: toolBarAttrImageClicked)
        
        let prevLabel2 = " \nPrevious"
        let prevLabelAttr2 = NSAttributedString(string: prevLabel2, attributes: toolBarAttrLabel)
        let prevLabelAttrClicked2 = NSAttributedString(string: prevLabel2, attributes: toolBarAttrLabelClicked)
        
        let completePrevLabel = NSMutableAttributedString()
        completePrevLabel.append(prevLabelAttr1)
        completePrevLabel.append(prevLabelAttr2)
        
        let completePrevLabelClicked = NSMutableAttributedString()
        completePrevLabelClicked.append(prevLabelAttrClicked1)
        completePrevLabelClicked.append(prevLabelAttrClicked2)
        
        let prev = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        prev.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        prev.setAttributedTitle(completePrevLabel, for: .normal)
        prev.setAttributedTitle(completePrevLabelClicked, for: .selected)
        prev.setAttributedTitle(completePrevLabelClicked, for: .highlighted)
        prev.titleLabel?.textAlignment = .center
        prev.addTarget(self, action: #selector(prevFunFact), for: .touchUpInside)
        let prevBtn = UIBarButtonItem(customView: prev)
        
        let nextLabel1 = String.fontAwesomeIcon(name: .arrowRight)
        let nextAttr1 = NSAttributedString(string: nextLabel1, attributes: toolBarAttrImage)
        let nextLabelAttrClicked1 = NSAttributedString(string: nextLabel1, attributes: toolBarAttrImageClicked)
        
        let nextLabel2 = "\nNext"
        let nextAttr2 = NSAttributedString(string: nextLabel2, attributes: toolBarAttrLabel)
        let nextLabelAttrClicked2 = NSAttributedString(string: nextLabel2, attributes: toolBarAttrLabelClicked)
        
        let completenextLabel = NSMutableAttributedString()
        completenextLabel.append(nextAttr1)
        completenextLabel.append(nextAttr2)
        
        let completeNextLabelClicked = NSMutableAttributedString()
        completeNextLabelClicked.append(nextLabelAttrClicked1)
        completeNextLabelClicked.append(nextLabelAttrClicked2)
        
        let next = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        next.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        next.setAttributedTitle(completenextLabel, for: .normal)
        next.setAttributedTitle(completeNextLabelClicked, for: .selected)
        next.setAttributedTitle(completeNextLabelClicked, for: .highlighted)
        next.titleLabel?.textAlignment = .center
        next.addTarget(self, action: #selector(nextFunFact), for: .touchUpInside)
        let nextBtn = UIBarButtonItem(customView: next)
        
        let shareLabel1 = String.fontAwesomeIcon(name: .shareAlt)
        let shareAttr1 = NSAttributedString(string: shareLabel1, attributes: Attributes.navBarImageSolidAttribute)
        let shareAttrClicked1 = NSAttributedString(string: shareLabel1, attributes: toolBarAttrImageClicked)
        
//        let shareLabel2 = "\nShare"
//        let shareAttr2 = NSAttributedString(string: shareLabel2, attributes: toolBarAttrLabel)
//        let shareAttrClicked2 = NSAttributedString(string: shareLabel2, attributes: toolBarAttrLabelClicked)
        
        let completeshareLabel = NSMutableAttributedString()
        completeshareLabel.append(shareAttr1)
//        completeshareLabel.append(shareAttr2)
        
        let completeshareLabelClicked = NSMutableAttributedString()
        completeshareLabelClicked.append(shareAttrClicked1)
//        completeshareLabelClicked.append(shareAttrClicked2)
        
        let share = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        share.isUserInteractionEnabled = true
        share.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        share.setAttributedTitle(completeshareLabel, for: .normal)
        share.setAttributedTitle(completeshareLabelClicked, for: .highlighted)
        share.setAttributedTitle(completeshareLabelClicked, for: .selected)
        share.titleLabel?.textAlignment = .center
        share.addTarget(self, action: #selector(shareFactAction), for: .touchUpInside)
        let shareBtn = UIBarButtonItem(customView: share)
        
        
        let menuLabel1 = String.fontAwesomeIcon(name: .angleDown)
        let menuAttr1 = NSAttributedString(string: menuLabel1, attributes: Attributes.navBarImageSolidAttribute)
        let menuAttrClicked1 = NSAttributedString(string: menuLabel1, attributes: toolBarAttrImageClicked)
         
        let completemenuLabel = NSMutableAttributedString()
        completemenuLabel.append(menuAttr1)
        
        let completemenuLabelClicked = NSMutableAttributedString()
        completemenuLabelClicked.append(menuAttrClicked1)
        
        let menu = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        menu.isUserInteractionEnabled = true
        menu.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        menu.setAttributedTitle(completemenuLabel, for: .normal)
        menu.setAttributedTitle(completemenuLabelClicked, for: .highlighted)
        menu.setAttributedTitle(completemenuLabelClicked, for: .selected)
        menu.titleLabel?.textAlignment = .center
        menu.addTarget(self, action: #selector(menuAction), for: .touchUpInside)
        let menuBtn = UIBarButtonItem(customView: menu)
        
        let voiceLabel1 = String.fontAwesomeIcon(name: .volumeUp)
        let voiceAttr1 = NSAttributedString(string: voiceLabel1, attributes: Attributes.navBarImageSolidAttribute)
        let voiceAttrClicked1 = NSAttributedString(string: voiceLabel1, attributes: toolBarAttrImageClicked)
        
        let completevoiceLabel = NSMutableAttributedString()
        completevoiceLabel.append(voiceAttr1)
        
        let completevoiceLabelClicked = NSMutableAttributedString()
        completevoiceLabelClicked.append(voiceAttrClicked1)
        
        let voice = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        voice.isUserInteractionEnabled = true
        voice.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        voice.setAttributedTitle(completevoiceLabel, for: .normal)
        voice.setAttributedTitle(completevoiceLabelClicked, for: .highlighted)
        voice.setAttributedTitle(completevoiceLabelClicked, for: .selected)
        voice.titleLabel?.textAlignment = .center
        voice.addTarget(self, action: #selector(voiceAction), for: .touchUpInside)
        let voiceBtn = UIBarButtonItem(customView: voice)
        
        let helpLabel1 = String.fontAwesomeIcon(name: .questionCircle)
        let helpAttr1 = NSAttributedString(string: helpLabel1, attributes: Attributes.navBarImageSolidAttribute)
        let helpAttrClicked1 = NSAttributedString(string: helpLabel1, attributes: Attributes.toolBarImageClickedAttribute)
        
        let completehelpLabel = NSMutableAttributedString()
        completehelpLabel.append(helpAttr1)
        
        let completehelpLabelClicked = NSMutableAttributedString()
        completehelpLabelClicked.append(helpAttrClicked1)
        
        let help = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        help.isUserInteractionEnabled = true
        help.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        help.setAttributedTitle(completehelpLabel, for: .normal)
        help.setAttributedTitle(completehelpLabelClicked, for: .highlighted)
        help.setAttributedTitle(completehelpLabelClicked, for: .selected)
        help.titleLabel?.textAlignment = .center
        help.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        let helpBtn = UIBarButtonItem(customView: help)
        
        navigationItem.setRightBarButtonItems([menuBtn, flexibleSpace, shareBtn, flexibleSpace, voiceBtn, flexibleSpace, helpBtn], animated: true)
    }
    @objc func showAlert() {
        quickHelpView = Utils.showQuickHelp()
        self.present(quickHelpView, animated: true, completion: nil)
    }
    private func setupPageControl() {
        self.pageControl.frame = CGRect(x: 0, y: self.view.frame.size.height - 50, width: self.view.frame.size.width, height: 50)
        self.pageControl.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        self.pageControl.backgroundColor = .clear
        self.pageControl.currentPageIndicatorTintColor = UIColor(white: 0.4, alpha: 1.0)
        self.pageControl.pageIndicatorTintColor = UIColor(white: 0.8, alpha: 1.0)
        self.pageControl.hidesForSinglePage = true
        self.view.addSubview(self.pageControl)
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            self.pageControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pageControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        self.pageControl.numberOfPages = pageContent.count
    }
    
    @objc func voiceAction(sender: UIButton) {
        if synth.isSpeaking {
            synth.stopSpeaking(at: .word)
            sender.isSelected = false
        }
        else {
            sender.isSelected = true
            let currentVC = viewControllerAtIndex(currentIndex)
            let funFactDescWOHashtags = currentVC?.funFactDesc.replacingOccurrences(of: "\\s?#(?:\\S+)\\s?",
                                                            with: "",
                                                            options: .regularExpression,
                                                            range: ((currentVC?.funFactDesc.startIndex)!..<(currentVC?.funFactDesc.endIndex)!)).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            let utterance = AVSpeechUtterance(string: funFactDescWOHashtags!)
            var voiceToUse: AVSpeechSynthesisVoice?
            print (AVSpeechSynthesisVoice.speechVoices())
            for voice in AVSpeechSynthesisVoice.speechVoices() {
                if voice.name == "Aaron" {
                    voiceToUse = voice
                }
            }
            utterance.voice = voiceToUse
            
            synth = AVSpeechSynthesizer()
            synth.delegate = self
            synth.speak(utterance)
        }
    }
    
    @objc func menuAction(sender: UIButton) {
        let currentVC = viewControllerAtIndex(currentIndex)!
        let actionSheetController: UIAlertController = UIAlertController(title: "Options", message: "Please select one of the following", preferredStyle: .actionSheet)

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)

        let addActionButton = UIAlertAction(title: "Add Fun Fact", style: .default)
        { _ in
            print("Save")
        }
        actionSheetController.addAction(addActionButton)

        if currentVC.submittedByObject as? String == AppDataSingleton.appDataSharedInstance.userProfile.uid {
            let editActionButton = UIAlertAction(title: "Edit Fun Fact", style: .default)
            { _ in
                guard let addFactVC  = self.storyboard?.instantiateViewController(withIdentifier: "addFactVC") as? AddNewFactViewController? else { return }
                addFactVC?.mode = "edit"
                addFactVC?.funFactID = currentVC.funFactID
                addFactVC?.landmarkName = currentVC.headingObject as? String
                addFactVC?.landmarkTypeText = currentVC.landmarkType
                addFactVC?.type = currentVC.landmarkType
                addFactVC?.imageCaptionText = currentVC.imageCaption
                addFactVC?.funFactDesc = currentVC.funFactDesc
                addFactVC?.landmarkID = currentVC.landmarkID
                addFactVC?.verificationFlag = currentVC.verifiedFlag
                addFactVC?.disputeFlag = currentVC.disputeFlag
                addFactVC?.likes = currentVC.likesObject as! Int
                addFactVC?.dislikes = currentVC.dislikesObject as! Int
                addFactVC?.source = currentVC.sourceObject as! String
                self.navigationController?.pushViewController(addFactVC!, animated: true)
                
            }
            actionSheetController.addAction(editActionButton)
            
            let deleteActionButton = UIAlertAction(title: "Delete Fun Fact", style: .default)
            { _ in
                print("Delete")
            }
            actionSheetController.addAction(deleteActionButton)
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @objc func shareFactAction(sender : UIButton) {
        let activityController: UIActivityViewController
        let currentVC = viewControllerAtIndex(currentIndex)!
        var imageToShare = UIImage()
        
        let imageFromCache = CacheManager.shared.getFromCache(key: "\(currentVC.funFactID).jpeg") as? UIImage
        if imageFromCache != nil {
            imageToShare = imageFromCache!
        }
        else {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(currentVC.funFactID).jpeg)")
            gsReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print ("Error getting image \(error.localizedDescription)")
                } else {
                    imageToShare = UIImage(data: data!)!
                }
            }
        }
        
        let funFact = "Did you know this fun fact about " + (currentVC.headingObject as! String) + "? \n" + currentVC.funFactDesc
        activityController = UIActivityViewController(activityItems: [funFact, imageToShare], applicationActivities: nil)
        activityController.excludedActivityTypes = [.airDrop, .addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .postToFlickr]
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    @objc func prevFunFact(sender : UIButton) {
        prevPage()
    }
    @objc func nextFunFact(sender : UIButton) {
        nextPage()
    }
    
    func nextPage() {
        if currentIndex+1 == totalPages {
            return
        }
        currentIndex += 1
        if let nextViewController = viewControllerAtIndex(currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
//            nextViewController.pageNumberText = "Fact (\(currentIndex+1)/\(totalPages))"
        }
    }
    func prevPage() {
        if currentIndex == 0 {
            return
        }
        currentIndex -= 1
        if let prevViewController = viewControllerAtIndex(currentIndex) {
            setViewControllers([prevViewController], direction: .reverse, animated: true, completion: nil)
//            prevViewController.pageNumberText = "Fact (\(currentIndex+1)/\(totalPages))"
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addFactVC = segue.destination as? AddNewFactViewController
        addFactVC?.address = currentVC.address
        addFactVC?.landmarkName = currentVC.headingObject as? String
    }
    public func createIndex<Key, Element>(elms:[Element], extractKey:(Element) -> Key) -> [Key:Element] where Key : Hashable {
        var dict = [Key:Element]()
        for elm in elms {
            dict[extractKey(elm)] = elm
        }
        return dict
    }
}
extension FunFactPageViewController: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print ("Finished speaking")
        let voiceBtn = navigationItem.rightBarButtonItems![4]
        (voiceBtn.customView as! UIButton).isSelected = false
    }
}
