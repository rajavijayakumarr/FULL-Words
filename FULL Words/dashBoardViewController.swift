//
//  dashBoardViewController.swift
//  FULL Words
//
//  Created by User on 19/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class dashBoardViewController: UIViewController {
    
    var userName: String?
    var emailId: String?

    @IBOutlet weak var userNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userNameLabel.text = userName
    }

}
