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
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = "Dashboard"
        
        let dashboard = self.viewControllers?.first as? dashBoardViewController
        let setting = self.viewControllers?.last as? settingsTableViewController
        if let userName = userName, let emailId = emailId {
            dashboard?.userName = userName
            dashboard?.emailId = emailId
            setting?.userName = userName
        }
    }

}
