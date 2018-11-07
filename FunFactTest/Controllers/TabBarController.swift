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
        tabBar.tintColor = Constants.redColor
        
        tabBar.items?[0].setTitleTextAttributes(Constants.toolBarLabelAttribute, for: .normal)
        tabBar.items?[0].setTitleTextAttributes(Constants.toolBarLabelClickedAttribute, for: .selected)
        tabBar.items?[0].title = "Home"
        tabBar.items?[0].image = UIImage.fontAwesomeIcon(name: .home,
                                                         style: .solid,
                                                         textColor: UIColor.darkGray,
                                                         size: CGSize(width: 30, height: 30))
        
        tabBar.items?[1].setTitleTextAttributes(Constants.toolBarLabelAttribute, for: .normal)
        tabBar.items?[1].setTitleTextAttributes(Constants.toolBarLabelClickedAttribute, for: .selected)
        tabBar.items?[1].title = "Profile"
        tabBar.items?[1].image = UIImage.fontAwesomeIcon(name: .user,
                                                         style: .solid,
                                                         textColor: UIColor.darkGray,
                                                         size: CGSize(width: 30, height: 30))
        
        tabBar.items?[2].setTitleTextAttributes(Constants.toolBarLabelAttribute, for: .normal)
        tabBar.items?[2].setTitleTextAttributes(Constants.toolBarLabelClickedAttribute, for: .selected)
        tabBar.items?[2].title = "Settings"
        tabBar.items?[2].image = UIImage.fontAwesomeIcon(name: .cog,
                                                         style: .solid,
                                                         textColor: UIColor.darkGray,
                                                         size: CGSize(width: 30, height: 30))
        
    }
}
