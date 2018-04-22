//
//  wordsTableViewController.swift
//  FULL Words
//
//  Created by User on 22/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit


class wordsTableViewController: UITableViewController {
    
    var addButtonBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonPressed))
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(addButtonBarButton, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.visibleViewController?.title = "Added Words"
    }

    @objc func addButtonPressed(){
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "newwordviewcontroller") as? newWordViewController
        
        self.present(wordsViewController!, animated: true, completion: nil)
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }


}


