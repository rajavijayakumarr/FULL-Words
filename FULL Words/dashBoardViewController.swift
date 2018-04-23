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
        userNameLabel.numberOfLines = 3
        userNameLabel.adjustsFontSizeToFitWidth = true
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.visibleViewController?.title = "Dashboard"
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)

    }

}
