//
//  userPageTabController.swift
//  FULL Words
//
//  Created by User on 19/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class UserPageTabController: UITabBarController {
    
    var userName: String?
    var emailId: String?
    var isUserAlreadyLoggedIn: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.visibleViewController?.title = "Words"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)
    
        
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.lightGray.cgColor
        self.tabBar.clipsToBounds = true
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = "Dashboard"
        
        let setting = self.viewControllers?.last as? SettingsTableViewController
        let wordsTable = self.viewControllers?.first as? WordsViewController
        
        if let userName = userName, let emailId = emailId {
            wordsTable?.userName = userName
            wordsTable?.isUserAlreadyLoggedIn = isUserAlreadyLoggedIn
            setting?.userName = userName
            setting?.emailId = emailId
           
        }
    }

}


// this class is just to make the images in the tabbar be in the middle of the view when the text is not present in the tabbar controller
class MainTabBar: UITabBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // iOS 11: puts the titles to the right of image for horizontal size class regular. Only want offset when compact.
        // iOS 9 & 10: always puts titles under the image. Always want offset.
        var verticalOffset: CGFloat = 6.0
        
        if #available(iOS 11.0, *), traitCollection.horizontalSizeClass == .regular {
            verticalOffset = 0.0
        }
        
        let imageInset = UIEdgeInsets(
            top: verticalOffset,
            left: 0.0,
            bottom: -verticalOffset,
            right: 0.0
        )
        
        for tabBarItem in items ?? [] {
            tabBarItem.title = ""
            tabBarItem.imageInsets = imageInset
        }
    }
}
