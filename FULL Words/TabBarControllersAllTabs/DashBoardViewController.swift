//
//  dashBoardViewController.swift
//  FULL Words
//
//  Created by User on 19/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DashBoardViewController: UIViewController {
    
    var userName: String?
    var emailId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        userNameLabel.adjustsFontSizeToFitWidth = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let greenColor =  #colorLiteral(red: 0.344810009, green: 0.7177901864, blue: 0.6215276122, alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = greenColor
        self.navigationController?.navigationBar.barTintColor = greenColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1) as Any]
        self.navigationController?.view.tintColor = #colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)
        
        navigationController?.visibleViewController?.navigationItem.title = "Dashboard"
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)
    }
    
}

