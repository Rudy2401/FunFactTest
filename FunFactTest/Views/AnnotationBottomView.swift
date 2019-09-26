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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if traitCollection.userInterfaceStyle == .light {
            self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        } else {
            self.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if traitCollection.userInterfaceStyle == .light {
            self.backgroundColor = .white
        } else {
            if #available(iOS 13.0, *) {
                self.backgroundColor = .systemGray3
            } else {
                self.backgroundColor = .black
            }
        }
    }
}
