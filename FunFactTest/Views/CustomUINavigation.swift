//
//  CustomUINavigation.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/28/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = Colors.seagreenColor
        self.navigationBar.tintColor = UIColor(white: 0.95, alpha: 1.0)
        self.navigationBar.isTranslucent = false
        if let customFont = UIFont(name: Fonts.boldFont, size: 25) {
            self.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: customFont
            ]
            self.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: customFont
            ]
        }
    }
}
