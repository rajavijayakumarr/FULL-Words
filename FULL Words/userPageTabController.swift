//
//  userPageTabController.swift
//  FULL Words
//
//  Created by User on 19/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class userPageTabController: UITabBarController {
    
    var userName: String?
    var emailId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.visibleViewController?.title = "Dashboard"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)
    
        
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.lightGray.cgColor
        self.tabBar.clipsToBounds = true
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = "Dashboard"
        
        let dashboard = self.viewControllers?.first as? dashBoardViewController
        let setting = self.viewControllers?.last as? settingsTableViewController
        // configure for the peerstableviewcontroller
        _ = self.viewControllers?[1] as? peersTableViewController
        let wordsTable = self.viewControllers?[2] as? wordsTableViewController
        let learnView = self.viewControllers?[3] as? learnViewController
        
        if let userName = userName, let emailId = emailId {
            learnView?.userName = userName
            learnView?.emailId = emailId
            wordsTable?.userName = userName
            dashboard?.userName = userName
            dashboard?.emailId = emailId
            setting?.userName = userName
            setting?.emailId = emailId
           
        }
    }

}
