//
//  settingsTableViewController.swift
//  FULL Words
//
//  Created by User on 19/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD


class SettingsTableViewController: UITableViewController {
    let VERSION_OF_THE_APPLICATION = "v 1.0 (1)"
    
    let settingsMenu = ["Profile", "Build & Version No:", "Sign Out"]
    
    var userName: String?
    var emailId: String?
    var pickedDaysToLearn: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        let whiteColor =  #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = whiteColor
        self.navigationController?.navigationBar.barTintColor = whiteColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) as Any]
        self.navigationController?.view.tintColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        
        self.navigationController?.visibleViewController?.navigationItem.title = "Settings"
        if let selection: IndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selection, animated: true)
        }
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
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
        case "Sign Out":
            cell.nameLabel.textColor = UIColor.red
            cell.accessoryType = .none
            cell.nameLabel.text = settingsMenu[indexPath.section]
            cell.nameLabel.font = cell.nameLabel.font.withSize(15)
            cell.infoLabel.text = ""
            
        case "Profile":
            cell.accessoryType = .none
            cell.nameLabel.text = settingsMenu[indexPath.section]
            cell.infoLabel.text = emailId
            cell.infoLabel.textColor = UIColor.gray
            
            
        case "Build & Version No:":
            cell.accessoryType = .none
            cell.nameLabel.text = settingsMenu[indexPath.section]
            cell.infoLabel.text = VERSION_OF_THE_APPLICATION
            cell.infoLabel.textColor = UIColor.gray

        default:
            break
            
        }
        cell.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        case 0:                                  //profile
            if let selection: IndexPath = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selection, animated: true)
            }
            
        case 1:                                  //Version
            if let selection: IndexPath = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selection, animated: true)
            }
        case 2:                                  //Logout
            let alert = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Sign Out", comment: ""), style: .destructive, handler:{ _ in
                
                let spinnerView = MBProgressHUD.showAdded(to: self.view, animated: true)
                spinnerView.label.text = "Logging out"
                //revoking the access token
                let accessToken = userValues.value(forKey: ACCESS_TOKEN) as! String
                var requestForRevokingToken = URLRequest(url: URL(string: "https://access.anywhereworks.com/o/oauth2/revoke?token=\(accessToken)")!)
                requestForRevokingToken.httpMethod = "GET"
                requestForRevokingToken.timeoutInterval = 6
                
                Alamofire.request(requestForRevokingToken).responseJSON { (responseData) in
                    if responseData.error == nil  {
                        let responseJSON_Data = JSON(responseData.data!)
                        if responseJSON_Data["ok"].boolValue {
                            //this is should be implemented after the user is successfully logged out and implement the loading screen here
                            
                            print(responseJSON_Data["ok"].boolValue)
                            
                            userValues.set(nil, forKey: REFRESH_TOKEN)
                            userValues.set(nil, forKey: ACCESS_TOKEN)
                            userValues.set(nil, forKey: TOKEN_TYPE)
                            userValues.set(nil, forKey: USER_NAME)
                            userValues.set(nil, forKey: EMAIL_ID)
                            userValues.set(false, forKey: USER_LOGGED_IN)
                            
                            MBProgressHUD.hide(for: self.view, animated: true)
                            
                            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "loginpageviewconroller") as? LoginPageViewController
                            self.navigationController?.viewControllers.insert((myVC! as UIViewController), at: (self.navigationController?.viewControllers.startIndex)!)
                            self.navigationController?.popToRootViewController(animated: true)
                        } else {
                            //this is where the token revolke process is not working as it should be
                            MBProgressHUD.hide(for: self.view, animated: true)
                            let alert = UIAlertController(title: "Could not Logout", message: "try again", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                                if let selection = tableView.indexPathForSelectedRow {
                                    tableView.deselectRow(at: selection, animated: true)
                                }
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }  else {
                        var title = "", message = ""
                        MBProgressHUD.hide(for: self.view, animated: true)
                        switch responseData.result {
                        case .failure(let error):
                            if error._code == NSURLErrorTimedOut {
                                title = "Server timed out!"
                                message = "try again"
                            } else {
                                title = "Netword error!"
                                message = "Check your internet connection and try again"
                            }
                        default: break
                        }
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                            if let selection = tableView.indexPathForSelectedRow {
                            tableView.deselectRow(at: selection, animated: true)
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {_ in
                if let selection: IndexPath = tableView.indexPathForSelectedRow{
                    tableView.deselectRow(at: selection, animated: true)
                }
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
        return 50
    }

}

///custome table view cell for the version lable and the profile lable
class tableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
}
