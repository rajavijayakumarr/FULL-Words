//
//  settingsTableViewController.swift
//  FULL Words
//
//  Created by User on 19/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit


class settingsTableViewController: UITableViewController {
    let VERSION_OF_THE_APPLICATION = "1.0"
    
    let settingsMenu = ["Profile", "No. Words to learn", "Version", "Logout"]
    
    var userName: String?
    var emailId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.visibleViewController?.title = "Settings"
        if let selection: IndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selection, animated: true)
        }
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath) as! tableCell
        
        switch settingsMenu[indexPath.section] {
        case "Logout":
            cell.nameLabel.textColor = UIColor.red
            cell.accessoryType = .disclosureIndicator
            cell.nameLabel.text = settingsMenu[indexPath.section]
            cell.infoLabel.text = ""
            
        case "Profile":
            cell.accessoryType = .none
            cell.nameLabel.text = settingsMenu[indexPath.section]
            cell.infoLabel.text = emailId
            
            
        case "Version":
            cell.accessoryType = .none
            cell.nameLabel.text = settingsMenu[indexPath.section]
            cell.infoLabel.text = VERSION_OF_THE_APPLICATION
        case "No. Words to learn":
            cell.accessoryType = .disclosureIndicator
            cell.nameLabel.text = settingsMenu[indexPath.section]
            cell.infoLabel.text = ""

        default:
            break
            
        }
        cell.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        case 0:
            if let selection: IndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selection, animated: true)
            }
           
        case 1:
            if let selection: IndexPath = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selection, animated: true)
            }
        case 2:
            if let selection: IndexPath = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selection, animated: true)
            }
        case 3:
            let alert = UIAlertController(title: "Confirmation!", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: {_ in
                if let selection: IndexPath = tableView.indexPathForSelectedRow{
                    tableView.deselectRow(at: selection, animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Logout", comment: ""), style: .destructive, handler:{ _ in
                
                
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
        return settingsMenu.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

///custome table view cell for the version lable and the profile lable
class tableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
}
