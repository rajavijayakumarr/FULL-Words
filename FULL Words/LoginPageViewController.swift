//
//  ViewController.swift
//  FULL Words
//
//  Created by User on 18/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import SwiftyJSON
import MBProgressHUD

let CLIENT_ID = "29354-dad2dd8a5dda745be5e6faea2a155d77"
let CLIENT_SECRET = "iOsdmGZj-8Tydm0sJ8l6N6dWCZ_e0uZQ5LTy2KfT"
let REDIRECT_URL = "com.FULL.FULL-Words://"
let CODE_URL = "https://access.anywhereworks.com/o/oauth2/auth"
let TOKEN_URL = "https://access.anywhereworks.com/o/oauth2/v1/token"

let USER_DETAILS_URL = "https://api.anywhereworks.com/api/v1/user/me"
let FULL_WORDS_API_URL = "https://full-learn.appspot.com/api/v1/words"
let FULL_WORDS_ME_API = "https://full-learn.appspot.com/api/v1/words/user/me?limit=10&cursor="
let FEEDS_URL = "https://api.anywhereworks.com/api/v1/feed"

let SCOPES = "awapis.identity+awapis.feeds.write"

let REFRESH_TOKEN = "ADAPTIVIEWU_REFRESH_TOKEN"
let ACCESS_TOKEN = "ADAPTIVIEWU_ACCESS_TOKEN"
let TOKEN_TYPE = "ADAPTIVIEWU_TOKEN_TYPE"
let UNIQUE_STATE_TOKEN = "validated_token"
let IS_USER_LOGGED_IN = "USER_LOGGED_IN"
let userDefaultsObject = UserDefaults.standard

let USER_NAME = "USER_NAME"
let EMAIL_ID = "EMAIL_ID"
let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class LoginPageViewController: UIViewController, UIScrollViewDelegate, SFSafariViewControllerDelegate{
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    var authenticationSession: SFAuthenticationSession? = nil
    var safariViewController: SFSafariViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let name = NSNotification.Name.init(rawValue: kCloseSafariViewControllerNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(self.safariLogin(notification:)), name: name, object: nil)
        
        loginButtonOutlet.layer.cornerRadius = 5
        loginButtonOutlet.clipsToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func loginButtonClicked(_ sender: UIButton) {
        let url = CODE_URL+"?response_type=code&client_id="+CLIENT_ID+"&access_type=offline&scope=\(SCOPES)&redirect_uri="+REDIRECT_URL+"&approval_prompt=force"
        self.safariViewController = SFSafariViewController(url: URL(string: url)!)
        self.safariViewController?.delegate = self
        self.present(self.safariViewController!, animated: true, completion: nil)
    }
    
    @objc func safariLogin(notification: NSNotification) {

        let url = notification.object as? URL
        let authenticationCode = self.getAuthenticationCode(from: url)
        guard authenticationCode != nil || authenticationCode == "access_denied" else {
            let alert = UIAlertController(title: "User cancelled", message: "Try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
   //     self.showLoadingView()
        
        let loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingView.label.text = "Signing in"
        
        
        print(url?.absoluteString ?? "nothing")
        print(authenticationCode!)
        
        var urlRequestForToken = URLRequest(url: URL(string: TOKEN_URL)!)
        
        var data:Data = "code=\(authenticationCode ?? "none")".data(using: .utf8)!
        data.append("&client_id=\(CLIENT_ID)".data(using: .utf8)!)
        data.append("&client_secret=\(CLIENT_SECRET)".data(using: .utf8)!)
        data.append("&redirect_uri=\(REDIRECT_URL)".data(using: .utf8)!)
        data.append("&grant_type=authorization_code".data(using: .utf8)!)
        urlRequestForToken.httpBody = data
        urlRequestForToken.httpMethod = "POST"
        urlRequestForToken.timeoutInterval = 60
        
        print(String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Any)
        Alamofire.request(urlRequestForToken).responseJSON { (responseData) in
            if responseData.error == nil{
                var JSONdata = JSON(responseData.data!)
                let accessToken = JSONdata["access_token"].stringValue
                let refreshToken = JSONdata["refresh_token"].stringValue
                let tokenType = JSONdata["token_type"].stringValue
                
                print("****************************************************************************************")
                print("accessToken: \(accessToken)\nrefreshToken: \(refreshToken)")
                userDefaultsObject.set(refreshToken, forKey: REFRESH_TOKEN)
                userDefaultsObject.set(accessToken, forKey: ACCESS_TOKEN)
                userDefaultsObject.set(tokenType, forKey: TOKEN_TYPE)
                
   //             self.changeLoadingLabel(lableToShowInLoading: "Loading . .")
                
                self.getUserDetails(access_Token: accessToken, token_Type: tokenType)
                
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
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.safariViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    func getUserDetails(access_Token accessToken: String, token_Type tokenType: String) -> Void {
        
        var urlRequestForUserDetails = URLRequest(url: URL(string: USER_DETAILS_URL)!)
        urlRequestForUserDetails.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
        urlRequestForUserDetails.httpMethod = "GET"
        urlRequestForUserDetails.timeoutInterval = 60
        
        Alamofire.request(urlRequestForUserDetails).responseJSON { (responseData) in
            if responseData.error == nil {
                var JSONdata = JSON(responseData.data!)
                print("****************************************************************************************")
                let firstName = JSONdata["data"]["user"]["firstName"].stringValue
                let lastName = JSONdata["data"]["user"]["lastName"].string
                let emailId = JSONdata["data"]["user"]["login"].stringValue
                print("****************************************************************************************")
                print("firstname: \(firstName)\nsecondname: \(lastName ?? "")\nemailId: \(emailId)")
                // do not add the lastName to the guard statement because some person may or maynot have a second name and they could not login into the account
                //bug 1
                guard firstName != "" && emailId != "" else {
                    let alert = UIAlertController(title: "Something went wrong!", message: "Try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    MBProgressHUD.hide(for: self.view, animated: true)
                    return
                }
                
                
                userDefaultsObject.set(firstName + " " + (lastName ?? "") , forKey: USER_NAME)
                userDefaultsObject.set(emailId, forKey: EMAIL_ID)
                userDefaultsObject.set(true, forKey: IS_USER_LOGGED_IN)
                
                
                
                let tabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "userTabBarViewController") as? UserPageTabController
                tabBarViewController?.userName = firstName + (lastName != "" ? " " + (lastName ?? ""): "")
                tabBarViewController?.emailId = emailId
                tabBarViewController?.isUserAlreadyLoggedIn = true
                
                if let tabBarViewController = tabBarViewController {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.navigationController?.pushViewController(tabBarViewController, animated: true)
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
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func getAuthenticationCode(from url:URL?) -> String? {

        let stringUrl:String! = url?.absoluteString
        let index = stringUrl?.index(after: stringUrl?.index(of: "=") ?? (stringUrl?.startIndex)!)
        var subS: String? = nil
        if index != nil {
        let substring = stringUrl[index!...]
            subS = String(substring)
        }
        return subS
    }
    
}

//to hide the back button globally in the navigation bar use this custom class for the uinavigatoncontroller
class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate = self
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }
}
