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
//
//    @IBOutlet var landmarkImage: UIImageView!
//    @IBOutlet var titleAnnotation: UILabel!
//    @IBOutlet var landmarkType: UILabel!
//    @IBOutlet var landmarkAddress: UILabel!
//    @IBOutlet var distance: UILabel!
//    @IBOutlet var likePercentage: UILabel!
//    @IBOutlet var numberOfFF: UILabel!
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupAttributes()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupAttributes()
//    }
//
//    func setupAttributes() {
////        Bundle.main.loadNibNamed("AnnotationBottomView", owner: self, options: nil)
//        self.frame = self.bounds
//        self.backgroundColor = UIColor.white
//        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        self.layer.borderWidth = CGFloat.init(0.2)
//        self.layer.borderColor = UIColor.lightGray.cgColor
//        self.layer.cornerRadius = 5
//    }
//
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.backgroundColor = UIColor.white

    }
}
