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
    @IBOutlet weak var scrollView: UIScrollView!
    var image: UIImage?
    var imageCaptionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        imageView.image = image
        imageCaption?.text = imageCaptionText
        navigationController?.navigationBar.backItem?.title = ""
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        
        imageView!.layer.cornerRadius = 11.0
        imageView!.clipsToBounds = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
