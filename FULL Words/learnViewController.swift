//
//  learnViewController.swift
//  FULL Words
//
//  Created by User on 24/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class learnViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.visibleViewController?.navigationItem.title = "Learn"
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
