//
//  ImageViewViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/29/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit

class ImageViewViewController: UIViewController, UIScrollViewDelegate{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel?
    @IBOutlet var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 10.0
        }
    }
    var image: UIImage?
    var imageCaptionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        imageView.image = image
        imageCaption?.text = imageCaptionText
        scrollView.contentSize = imageView.frame.size
        navigationController?.navigationBar.backItem?.title = ""
        view.bringSubviewToFront(imageCaption!)
        setupGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self,
                                                      action: #selector(handleSwipe))
        swipeUpGesture.direction = .up
        scrollView.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self,
                                                      action: #selector(handleSwipe))
        swipeDownGesture.direction = .down
        scrollView.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc func handleSwipe(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .fade
            transition.subtype = CATransitionSubtype.fromTop
            navigationController?.view.layer.add(transition, forKey: nil)
            navigationController?.popViewController(animated: false)
        }
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale / 3.0,
                                            center: recognizer.location(in: recognizer.view))
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        if let imageV = self.imageView {
            zoomRect.size.height = imageV.frame.size.height / scale
            zoomRect.size.width  = imageV.frame.size.width  / scale
            let newCenter = imageV.convert(center, from: self.scrollView)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0))
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0))
        }
        return zoomRect
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.toolbar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.toolbar.isHidden = false
    }

}
