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
        let wordsTable = self.viewControllers?.first as? WordsTableViewController
        
        if let userName = userName, let emailId = emailId {
            wordsTable?.userName = userName
            setting?.userName = userName
            setting?.emailId = emailId
           
        }
    }

}
