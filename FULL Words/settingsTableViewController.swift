//
//  settingsTableViewController.swift
//  FULL Words
//
//  Created by User on 19/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit


class settingsTableViewController: UITableViewController {
    
    let settingsMenu = ["Profile", "View Status", "Logout" ]
    
    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingstableviewcell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.visibleViewController?.title = "Settings"
        if let selection: IndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selection, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsMenu.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingstableviewcell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.tag = indexPath.row
        cell.textLabel?.text = settingsMenu[indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.item {
            
        case 0:
            if let selection: IndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selection, animated: true)
            }
           
        case 1:
            if let selection: IndexPath = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selection, animated: true)
            }
            
        case 2:
            let alert = UIAlertController(title: "Confirmation!", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: {_ in
                if let selection: IndexPath = tableView.indexPathForSelectedRow{
                    tableView.deselectRow(at: selection, animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Logout", comment: ""), style: .default, handler:{ _ in
                
                
                userValues.set(nil, forKey: ADAPTIVIEWU_REFRESH_TOKEN)
                userValues.set(nil, forKey: ADAPTIVIEWU_ACCESS_TOKEN)
                userValues.set(nil, forKey: ADAPTIVIEWU_TOKEN_TYPE)
                userValues.set(nil, forKey: USER_NAME)
                userValues.set(nil, forKey: EMAIL_ID)
                userValues.set(false, forKey: USER_LOGGED_IN)
                
              
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "loginpageviewconroller") as? ViewController
                self.navigationController?.viewControllers.insert((myVC! as UIViewController), at: (self.navigationController?.viewControllers.startIndex)!)
                self.navigationController?.popToRootViewController(animated: true)

            }))
            
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

}
