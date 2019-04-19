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
import FirebaseDynamicLinks

class FunFactPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, FirestoreManagerDelegate {
    
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
    var funFacts = [FunFact]()
    var funFactDict = [String: [FunFact]]()
    var currentVC = ContentViewController()
    var synth = AVSpeechSynthesizer()
    var pageContent = NSArray()
    let pageControl = UIPageControl()
    var quickHelpView = UIAlertController()
    let pageNumLabel = UILabel()
    var firestore = FirestoreManager()
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if (currentIndex == 0) || (currentIndex == NSNotFound) {
            return nil
        }
        return viewControllerAtIndex(currentIndex-1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex == NSNotFound {
            return nil
        }
        if currentIndex+1 == totalPages {
            return nil
        }
        return viewControllerAtIndex(currentIndex+1)
    }
    func documentsDidUpdate() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.totalPages = pageContent.count
        self.view.backgroundColor = .white
        setupPageControl()
        
        setupToolbarAndNavigationbar()
        if AppDataSingleton.appDataSharedInstance.url != nil {
            guard let funFactID = AppDataSingleton.appDataSharedInstance.url?.valueOf("funFactID") else { return }
            setViewControllers([viewControllerAtIndex(getIndexOfVC(for: funFactID))] as? [UIViewController], direction: .forward, animated: true, completion: nil)
            pageControl.currentPage = getIndexOfVC(for: funFactID)
            currentIndex = getIndexOfVC(for: funFactID)
            pageNumLabel.text = "[\(currentIndex + 1)/\(totalPages)]"
            AppDataSingleton.appDataSharedInstance.url = nil
        } else {
            self.setViewControllers([viewControllerAtIndex(0)] as? [UIViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers?.last
        self.pageControl.currentPage = pageContent.index(of: pageContentViewController!)
        
        if (!completed && currentIndex==0) {
            
        }
        if (completed && finished) {
            if let currentVC = pageViewController.viewControllers?.last {
                currentIndex = indexOfViewController(viewController: currentVC as! ContentViewController)
                self.pageControl.currentPage = currentIndex
                pageNumLabel.text = "[\(currentIndex + 1)/\(totalPages)]"
            }
        }
    }
    
    func viewControllerAtIndex(_ index: Int) -> ContentViewController? {
        if (funFacts.count == 0) || (index >= funFacts.count) {
            return nil
        }
        
        let dataViewController = self.storyboard?.instantiateViewController(withIdentifier: "contentView") as! ContentViewController
        navigationItem.title = headingContent
        if headingContent == "" {
            firestore.getLandmarkName(for: landmarkID) { (landmarkName, error) in
                if let error = error {
                    print ("Error getting landmark Name \(error)")
                } else {
                    self.navigationItem.title = landmarkName
                    self.headingContent = landmarkName ?? ""
                }
            }
        }
        
        dataViewController.funFact = funFacts[index]
        dataViewController.address = address
        dataViewController.landmarkID = landmarkID
        dataViewController.currPageNumberText = String(index+1)
        dataViewController.totalPageNumberText = String(totalPages)
        currentVC = dataViewController
        return dataViewController
    }
    
    func getIndexOfVC(for funFactID: String) -> Int {
        let array = NSMutableArray(array: pageContent)
        let ids = array as? [String]
        return ids?.firstIndex(of: funFactID) ?? 0
    }
    
    func indexOfViewController(viewController: ContentViewController) -> Int {
        if let dataObject = viewController.funFact.id as? AnyObject {
            return pageContent.index(of: dataObject)
        } else {
            return NSNotFound
        }
    }
    
    func setupToolbarAndNavigationbar () {
        let toolBarAttrImageClicked = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                                 NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 30, style: .solid)]
        
        let shareLabel1 = String.fontAwesomeIcon(name: .shareAlt)
        let shareAttr1 = NSAttributedString(string: shareLabel1, attributes: Attributes.navBarImageLightAttribute)
        let shareAttrClicked1 = NSAttributedString(string: shareLabel1, attributes: toolBarAttrImageClicked)
        
        let completeshareLabel = NSMutableAttributedString()
        completeshareLabel.append(shareAttr1)
        
        let completeshareLabelClicked = NSMutableAttributedString()
        completeshareLabelClicked.append(shareAttrClicked1)
        
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
        let menuAttr1 = NSAttributedString(string: menuLabel1, attributes: Attributes.navBarImageLightAttribute)
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
        let voiceAttr1 = NSAttributedString(string: voiceLabel1, attributes: Attributes.navBarImageLightAttribute)
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
        let helpAttr1 = NSAttributedString(string: helpLabel1, attributes: Attributes.navBarImageLightAttribute)
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
        
        pageNumLabel.text = "[\(currentIndex + 1)/\(totalPages)]"
        pageNumLabel.font = UIFont(name: Fonts.demiBoldFont, size: 16.0)
        pageNumLabel.textColor = .white
        pageNumLabel.textAlignment = .right
        let pageNumBtn = UIBarButtonItem(customView: pageNumLabel)
        let currWidth = pageNumBtn.customView?.widthAnchor.constraint(equalToConstant: 60)
        currWidth?.isActive = true
        
        navigationItem.setRightBarButtonItems([menuBtn, Flex.flexibleSpace, shareBtn, Flex.flexibleSpace, voiceBtn, Flex.flexibleSpace, helpBtn, Flex.flexibleSpace, pageNumBtn], animated: true)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    @objc func showAlert() {
        quickHelpView = Utils.showQuickHelp()
        self.present(quickHelpView, animated: true, completion: nil)
    }
    private func setupPageControl() {
        self.pageControl.frame = CGRect(x: 0, y: self.view.frame.size.height - 50, width: self.view.frame.size.width, height: 50)
        self.pageControl.backgroundColor = .white
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
        self.pageControl.addTarget(self, action: #selector(pageControlSelectionAction), for: .touchUpInside)
    }
    
    @objc func pageControlSelectionAction(sender: UIPageControl) {
        if sender.currentPage > currentIndex {
            nextPage()
        } else {
            prevPage()
        }
    }
    
    @objc func voiceAction(sender: UIButton) {
        if synth.isSpeaking {
            synth.stopSpeaking(at: .word)
            sender.isSelected = false
        }
        else {
            sender.isSelected = true
            let currentVC = viewControllerAtIndex(currentIndex)
            let funFactDescWOHashtags = currentVC?.funFact.description.replacingOccurrences(of: "\\s?#(?:\\S+)\\s?",
                                                            with: "",
                                                            options: .regularExpression,
                                                            range: ((currentVC?.funFact.description.startIndex)!..<(currentVC?.funFact.description.endIndex)!)).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
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

        if currentVC.funFact.submittedBy == AppDataSingleton.appDataSharedInstance.userProfile.uid {
            let editActionButton = UIAlertAction(title: "Edit Fun Fact", style: .default)
            { _ in
                guard let addFactVC  = self.storyboard?.instantiateViewController(withIdentifier: "addFactVC") as? AddNewFactViewController? else { return }
                addFactVC?.mode = Mode.edit
                addFactVC?.funFactID = currentVC.funFact.id
                addFactVC?.landmarkID = currentVC.landmarkID
                addFactVC?.approvalCount = currentVC.funFact.approvalCount
                addFactVC?.rejectionCount = currentVC.funFact.rejectionCount
                addFactVC?.approvalUsers = currentVC.funFact.approvalUsers
                addFactVC?.rejectionUsers = currentVC.funFact.rejectionUsers
                addFactVC?.rejectionReason = currentVC.funFact.rejectionReason
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
        let currentVC = viewControllerAtIndex(currentIndex)!
        let storage = Storage.storage()
        let httpsReference = storage.reference(forURL: "https://firebasestorage.googleapis.com/v0/b/funfacts-5b1a9.appspot.com/o/images%2F\(currentVC.funFact.image).jpeg")
        httpsReference.downloadURL { imageUrl, error in
            if let error = error {
                print ("Error getting image \(error.localizedDescription)")
            } else {
                guard let link = URL(string: "https://funfactsproject/?landmarkID=\(self.landmarkID)&funFactID=\(currentVC.funFact.id)&apn=com.rushi.FunFact&d=1") else { return }
                let dynamicLinksDomainURIPrefix = "funfactsproject.page.link"
                
                let linkBuilder = DynamicLinkComponents(link: link, domain: dynamicLinksDomainURIPrefix)
                linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.rushi.FunFact")
                linkBuilder.iOSParameters?.appStoreID = "962194608"
                linkBuilder.iOSParameters?.minimumAppVersion = "1.0"
                
                //        linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.rushi.FunFact")
                //        linkBuilder.androidParameters?.minimumVersion = 1
                
                linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                linkBuilder.socialMetaTagParameters?.title = self.headingContent
                linkBuilder.socialMetaTagParameters?.descriptionText = currentVC.funFact.description
                linkBuilder.socialMetaTagParameters?.imageURL = imageUrl!
                
                print ("image URL = \(imageUrl!)")
                
                guard let longDynamicLink = linkBuilder.url else { return }
                print("The long URL is: \(longDynamicLink)")
                DynamicLinks.performDiagnostics(completion: nil)
                
                let options = DynamicLinkComponentsOptions()
                options.pathLength = .short
                linkBuilder.options = options
                
                linkBuilder.shorten { url, warnings, error in
                    if let error = error {
                        print ("Error while shortening \(error.localizedDescription)")
                    } else {
                        let shortUrl = url!
                        print("The short URL is: \(shortUrl.absoluteString)")
                        var activityController: UIActivityViewController
                        let funFact = "Checkout this cool fun fact: \(shortUrl)"
                        activityController = UIActivityViewController(activityItems: [funFact], applicationActivities: nil)
                        activityController.excludedActivityTypes = [.airDrop, .addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .postToFlickr]
                        
                        self.present(activityController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    func nextPage() {
        if currentIndex+1 == totalPages {
            return
        }
        currentIndex += 1
        if let nextViewController = viewControllerAtIndex(currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
            pageNumLabel.text = "[\(currentIndex + 1)/\(totalPages)]"
        }
    }
    func prevPage() {
        if currentIndex == 0 {
            return
        }
        currentIndex -= 1
        if let prevViewController = viewControllerAtIndex(currentIndex) {
            setViewControllers([prevViewController], direction: .reverse, animated: true, completion: nil)
            pageNumLabel.text = "[\(currentIndex + 1)/\(totalPages)]"
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addFactVC = segue.destination as? AddNewFactViewController
        addFactVC?.address = currentVC.address
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
