//
//  TabBarController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 11/7/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = Colors.seagreenColor

        tabBar.items?[0].setTitleTextAttributes(Attributes.toolBarLabelAttribute, for: .normal)
        tabBar.items?[0].setTitleTextAttributes(Attributes.toolBarLabelClickedAttribute, for: .selected)
        tabBar.items?[0].title = "Home"
        tabBar.items?[0].image = UIImage.fontAwesomeIcon(name: .home,
                                                         style: .light,
                                                         textColor: UIColor.darkGray,
                                                         size: CGSize(width: 30, height: 30))
        tabBar.items?[0].selectedImage = UIImage.fontAwesomeIcon(name: .home,
                                                                 style: .solid,
                                                                 textColor: UIColor.darkGray,
                                                                 size: CGSize(width: 30, height: 30))
        tabBar.items?[0].accessibilityIdentifier = "tabHome"
        tabBar.items?[0].accessibilityValue = "Home"
        
        tabBar.items?[1].setTitleTextAttributes(Attributes.toolBarLabelAttribute, for: .normal)
        tabBar.items?[1].setTitleTextAttributes(Attributes.toolBarLabelClickedAttribute, for: .selected)
        tabBar.items?[1].title = "Profile"
        tabBar.items?[1].image = UIImage.fontAwesomeIcon(name: .user,
                                                         style: .light,
                                                         textColor: .black,
                                                         size: CGSize(width: 30, height: 30))
        tabBar.items?[1].selectedImage = UIImage.fontAwesomeIcon(name: .user,
                                                                 style: .solid,
                                                                 textColor: .darkGray,
                                                                 size: CGSize(width: 30, height: 30))
        tabBar.items?[1].accessibilityIdentifier = "tabProfile"
        tabBar.items?[1].accessibilityValue = "Profile"
        
        tabBar.items?[2].setTitleTextAttributes(Attributes.toolBarLabelAttribute, for: .normal)
        tabBar.items?[2].setTitleTextAttributes(Attributes.toolBarLabelClickedAttribute, for: .selected)
        tabBar.items?[2].title = "Settings"
        tabBar.items?[2].image = UIImage.fontAwesomeIcon(name: .cog,
                                                         style: .light,
                                                         textColor: UIColor.darkGray,
                                                         size: CGSize(width: 30, height: 30))
        tabBar.items?[2].selectedImage = UIImage.fontAwesomeIcon(name: .cog,
                                                                 style: .solid,
                                                                 textColor: UIColor.darkGray,
                                                                 size: CGSize(width: 30, height: 30))
        tabBar.items?[2].accessibilityIdentifier = "tabSettings"
        tabBar.items?[2].accessibilityValue = "Settings"
        
        tabBar.items?[3].setTitleTextAttributes(Attributes.toolBarLabelAttribute, for: .normal)
        tabBar.items?[3].setTitleTextAttributes(Attributes.toolBarLabelClickedAttribute, for: .selected)
        tabBar.items?[3].title = "Search"
        tabBar.items?[3].image = UIImage.fontAwesomeIcon(name: .search,
                                                         style: .light,
                                                         textColor: UIColor.darkGray,
                                                         size: CGSize(width: 30, height: 30))
        tabBar.items?[3].selectedImage = UIImage.fontAwesomeIcon(name: .search,
                                                                 style: .solid,
                                                                 textColor: UIColor.darkGray,
                                                                 size: CGSize(width: 30, height: 30))
        tabBar.items?[3].accessibilityIdentifier = "tabSearch"
        tabBar.items?[3].accessibilityValue = "Search"
    }
}
