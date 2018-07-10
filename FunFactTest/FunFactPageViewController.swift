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
    var pageContent = NSArray()
    var imageContent = NSArray()
    var submittedByContent = NSArray()
    var sourceContent = NSArray()
    var likesContent = NSArray()
    var headingContent: String = ""
    var dateContent = NSArray()
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print ("In pageViewController before")
        var index = indexOfViewController(viewController: viewController
            as! ContentViewController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print ("In pageViewController after")
        var index = indexOfViewController(viewController: viewController
            as! ContentViewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == pageContent.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    required init?(coder aDecoder: NSCoder) {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .darkGray
        
        configurePageControl()
        self.setViewControllers([viewControllerAtIndex(0)] as? [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
    }
    
    func configurePageControl() {
        
        self.pageControl.numberOfPages = self.pageContent.count
        
        self.pageControl.alpha = 0.5
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = pageContent.index(of: pageContentViewController)
    }

    
    func viewControllerAtIndex(_ index: Int) -> ContentViewController? {
        print ("In viewControllerAtIndex 1")
        if (pageContent.count == 0) ||
            (index >= pageContent.count) {
            return nil
        }
        print ("In viewControllerAtIndex 2")
        let dataViewController = self.storyboard?.instantiateViewController(withIdentifier: "contentView") as! ContentViewController
        dataViewController.dataObject = pageContent[index] as AnyObject
        dataViewController.imageObject = imageContent[index] as AnyObject
        dataViewController.submittedByObject = submittedByContent[index] as AnyObject
        dataViewController.dateObject = dateContent[index] as AnyObject
        dataViewController.sourceObject = sourceContent[index] as AnyObject
        dataViewController.likesObject = likesContent[index] as AnyObject
        dataViewController.headingObject = headingContent as AnyObject
        dataViewController.pageNumberObject = "Fact (\(index+1)/\(pageContent.count))" as AnyObject
        
        return dataViewController
    }
    
    func indexOfViewController(viewController: ContentViewController) -> Int {
        
        if let dataObject: AnyObject = viewController.dataObject {
            return pageContent.index(of: dataObject)
        } else {
            return NSNotFound
        }
    }
}
