//
//  FunFactPageViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/27/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit

class FunFactPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageControl: UIPageControl
    var listOfFunFacts = ListOfFunFacts.init(listOfFunFacts: [])
    var pageContent = NSArray()
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
    var funFactDict = [String: [FunFact]]()
    var listOfLandmarks = ListOfLandmarks.init(listOfLandmarks: [])
    var userProfile = User(uid: "", dislikeCount: 0, disputeCount: 0, likeCount: 0, submittedCount: 0, email: "", name: "", phoneNumber: "", photoURL: "", provider: "", funFactsDisputed: [], funFactsLiked: [], funFactsDisliked: [], funFactsSubmitted: [])
    
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
    
    required init?(coder aDecoder: NSCoder) {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        self.dataSource = self
        self.delegate = self
        
        funFactDict = Dictionary(grouping: listOfFunFacts.listOfFunFacts, by: { $0.landmarkId })
        
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
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = pageContent.index(of: pageContentViewController)
        
        if (!completed && currentIndex==0) {
            
        }
        if (completed && finished) {
            if let currentVC = pageViewController.viewControllers?.last {
                currentIndex = indexOfViewController(viewController: currentVC as! ContentViewController)
                let pageNum = UILabel()
                pageNum.font = UIFont(name: "Avenir Next", size: 15.0)
                pageNum.text = "Fact (\(currentIndex+1)/\(totalPages))"
                let pageNumBarBtn = UIBarButtonItem(customView: pageNum)
                navigationItem.setRightBarButtonItems([pageNumBarBtn], animated: false)
            }
        }
    }

    
    func viewControllerAtIndex(_ index: Int) -> ContentViewController? {
        
        if ((funFactDict[landmarkID]?.count)! == 0) ||
            (index >= (funFactDict[landmarkID]?.count)!) {
            return nil
        }
        self.totalPages = (funFactDict[landmarkID]?.count)!
        
        if (currentIndex==0) {
            let pageNum = UILabel()
            pageNum.font = UIFont(name: "Avenir Next", size: 15.0)
            pageNum.text = "Fact (\(1)/\(totalPages))"
            let searchBarBtn = UIBarButtonItem(customView: pageNum)
            navigationItem.setRightBarButtonItems([searchBarBtn], animated: false)
        }
        
        let dataViewController = self.storyboard?.instantiateViewController(withIdentifier: "contentView") as! ContentViewController
        navigationItem.title = headingContent
        dataViewController.dataObject = funFactDict[landmarkID]![index].id as AnyObject
        dataViewController.funFactDesc = funFactDict[landmarkID]![index].description as String
        dataViewController.imageObject = funFactDict[landmarkID]![index].image as AnyObject
        dataViewController.submittedByObject = funFactDict[landmarkID]![index].submittedBy as AnyObject
        dataViewController.dateObject = funFactDict[landmarkID]![index].dateSubmitted as AnyObject
        dataViewController.sourceObject = funFactDict[landmarkID]![index].source as AnyObject
        dataViewController.verifiedFlag = funFactDict[landmarkID]![index].verificationFlag
        dataViewController.disputeFlag = funFactDict[landmarkID]![index].disputeFlag
        dataViewController.imageCaption = funFactDict[landmarkID]![index].imageCaption
        dataViewController.tags = funFactDict[landmarkID]![index].tags
        if (funFactDict[landmarkID]![index].likes + funFactDict[landmarkID]![index].dislikes) == 0 {
            dataViewController.likesObject = " 0%" as AnyObject
        }
        else {
            dataViewController.likesObject = (String(funFactDict[landmarkID]![index].likes * 100 / (funFactDict[landmarkID]![index].likes + funFactDict[landmarkID]![index].dislikes)) + "% found this interesting") as AnyObject
        }
        dataViewController.funFactID = funFactDict[landmarkID]![index].id
        dataViewController.address = address
        dataViewController.headingObject = headingContent as AnyObject
        dataViewController.listOfFunFacts = listOfFunFacts
        dataViewController.listOfLandmarks = listOfLandmarks
        dataViewController.userProfile = userProfile
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
        let toolBarAttrImage = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                 NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .solid)]
        let toolBarAttrLabel = [ NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0),
                                 NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
        
        let toolBarAttrImageClicked = [ NSAttributedString.Key.foregroundColor: Constants.redColor,
                                 NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 30, style: .solid)]
        let toolBarAttrLabelClicked = [ NSAttributedString.Key.foregroundColor: Constants.redColor,
                                 NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 10.0)!]
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let addFactLabel1 = String.fontAwesomeIcon(name: .plus)
        let addFactLabelAttr1 = NSAttributedString(string: addFactLabel1, attributes: toolBarAttrImage)
        let addFactLabelAttrClicked1 = NSAttributedString(string: addFactLabel1, attributes: toolBarAttrImageClicked)
        
        let addFactLabel2 = "\nAdd Fact"
        let addFactLabelAttr2 = NSAttributedString(string: addFactLabel2, attributes: toolBarAttrLabel)
        let addFactLabelAttrClicked2 = NSAttributedString(string: addFactLabel2, attributes: toolBarAttrLabelClicked)
        
        let completeAddFactLabel = NSMutableAttributedString()
        completeAddFactLabel.append(addFactLabelAttr1)
        completeAddFactLabel.append(addFactLabelAttr2)
        
        let completeAddFactLabelClicked = NSMutableAttributedString()
        completeAddFactLabelClicked.append(addFactLabelAttrClicked1)
        completeAddFactLabelClicked.append(addFactLabelAttrClicked2)
        
        let addFact = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        addFact.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        addFact.setAttributedTitle(completeAddFactLabel, for: .normal)
        addFact.setAttributedTitle(completeAddFactLabelClicked, for: .selected)
        addFact.setAttributedTitle(completeAddFactLabelClicked, for: .highlighted)
        addFact.titleLabel?.textAlignment = .center

        let addFactBtn = UIBarButtonItem(customView: addFact)
        
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
        let shareAttr1 = NSAttributedString(string: shareLabel1, attributes: toolBarAttrImage)
        let shareAttrClicked1 = NSAttributedString(string: shareLabel1, attributes: toolBarAttrImageClicked)
        
        let shareLabel2 = "\nShare Fact"
        let shareAttr2 = NSAttributedString(string: shareLabel2, attributes: toolBarAttrLabel)
        let shareAttrClicked2 = NSAttributedString(string: shareLabel2, attributes: toolBarAttrLabelClicked)
        
        let completeshareLabel = NSMutableAttributedString()
        completeshareLabel.append(shareAttr1)
        completeshareLabel.append(shareAttr2)
        
        let completeshareLabelClicked = NSMutableAttributedString()
        completeshareLabelClicked.append(shareAttrClicked1)
        completeshareLabelClicked.append(shareAttrClicked2)
        
        let share = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 10, height: self.view.frame.size.height))
        share.isUserInteractionEnabled = true
        share.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        share.setAttributedTitle(completeshareLabel, for: .normal)
        share.setAttributedTitle(completeshareLabelClicked, for: .highlighted)
        share.setAttributedTitle(completeshareLabelClicked, for: .selected)
        share.titleLabel?.textAlignment = .center
        share.addTarget(self, action: #selector(shareFactAction), for: .touchUpInside)
        let shareBtn = UIBarButtonItem(customView: share)
        
        let toolBarItems: [UIBarButtonItem]
        toolBarItems = [prevBtn, flexibleSpace, addFactBtn, flexibleSpace, shareBtn, flexibleSpace, nextBtn ]
        self.setToolbarItems(toolBarItems, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    @objc func shareFactAction(sender : UIButton) {
        let activityController: UIActivityViewController
        
        for ff in listOfFunFacts.listOfFunFacts {
            if ff.landmarkId == landmarkID {
                funFactDict[landmarkID]!.append(ff)
            }
        }
        let funFact = "Did you know this fun fact about " + headingContent + "? \n" + funFactDict[landmarkID]![currentIndex].description
        if let imageToShare = UIImage(named: listOfFunFacts.listOfFunFacts[currentIndex].image) {
            activityController = UIActivityViewController(activityItems: [funFact, imageToShare], applicationActivities: nil)
        } else  {
            activityController = UIActivityViewController(activityItems: [funFact], applicationActivities: nil)
        }
        
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
            let pageNum = UILabel()
            pageNum.font = UIFont(name: "Avenir Next", size: 15.0)
            pageNum.text = "Fact (\(currentIndex+1)/\(totalPages))"
            let searchBarBtn = UIBarButtonItem(customView: pageNum)
            navigationItem.setRightBarButtonItems([searchBarBtn], animated: false)
        }
    }
    func prevPage() {
        if currentIndex == 0 {
            return
        }
        currentIndex -= 1
        if let prevViewController = viewControllerAtIndex(currentIndex) {
            setViewControllers([prevViewController], direction: .reverse, animated: true, completion: nil)
            let pageNum = UILabel()
            pageNum.font = UIFont(name: "Avenir Next", size: 15.0)
            pageNum.text = "Fact (\(currentIndex+1)/\(totalPages))"
            let searchBarBtn = UIBarButtonItem(customView: pageNum)
            navigationItem.setRightBarButtonItems([searchBarBtn], animated: false)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //         Get the new view controller using segue.destinationViewController.
        //         Pass the selected object to the new view controller.
//        let destinationVC = segue.destination as? AddFactViewController
//        destinationVC?.address = address
//        let backItem = UIBarButtonItem()
//        backItem.title = ""
//        navigationItem.backBarButtonItem = backItem
    }
    public func createIndex<Key, Element>(elms:[Element], extractKey:(Element) -> Key) -> [Key:Element] where Key : Hashable {
        var dict = [Key:Element]()
        for elm in elms {
            dict[extractKey(elm)] = elm
        }
        return dict
    }
}
