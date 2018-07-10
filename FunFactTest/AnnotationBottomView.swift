//
//  AnnotationBottomView.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 6/20/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit

class AnnotationBottomView: UIView {
    
    @IBOutlet var landmarkImage: UIImageView!
    @IBOutlet var titleAnnotation: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var landmarkType: UILabel!
    @IBOutlet var landmarkAddress: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var likePercentage: UILabel!
    @IBOutlet var numberOfFF: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAttributes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAttributes()
    }
    
    func setupAttributes() {
        Bundle.main.loadNibNamed("AnnotationBottomView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.borderWidth = CGFloat.init(0.2)
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 5
    }
}
