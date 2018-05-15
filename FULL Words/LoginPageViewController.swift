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

let USER_DETAILS_SCOPE_URL = "https://api.anywhereworks.com/api/v1/user/me"
let FULL_WORDS_SCOPE_URL = "https://full-learn.appspot.com/api/v1/words"
let FEEDS_SCOPE_URL = "https://api.anywhereworks.com/api/v1/feed"

let REFRESH_TOKEN = "ADAPTIVIEWU_REFRESH_TOKEN"
let ACCESS_TOKEN = "ADAPTIVIEWU_ACCESS_TOKEN"
let TOKEN_TYPE = "ADAPTIVIEWU_TOKEN_TYPE"
let UNIQUE_STATE_TOKEN_VERIFY = "validated_token"
let USER_LOGGED_IN = "USER_LOGGED_IN"
let userValues = UserDefaults.standard

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

    @IBAction func loginWithAdaptvantButtonClicked(_ sender: UIButton) {
        let url = CODE_URL+"?response_type=code&client_id="+CLIENT_ID+"&access_type=offline&scope=awapis.identity+awapis.feeds.write&redirect_uri="+REDIRECT_URL+"&approval_prompt=force"
        
        self.safariViewController = SFSafariViewController(url: URL(string: url)!)
        self.safariViewController?.delegate = self
        self.present(self.safariViewController!, animated: true, completion: nil)
        
    }
    
    @objc func safariLogin(notification: NSNotification) {

        let url = notification.object as? URL
        let authenticationCode = self.getTheAuthenticationCode(from: url)
        guard authenticationCode != nil || authenticationCode == "access_denied" else {
            let alert = UIAlertController(title: "User cancelled", message: "Try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
   //     self.showLoadingView()
        
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Signing in"
        
        
        print(url?.absoluteString ?? "nothing")
        print(authenticationCode!)
        
        var requestForGettingToken = URLRequest(url: URL(string: TOKEN_URL)!)
        
        var data:Data = "code=\(authenticationCode ?? "none")".data(using: .utf8)!
        data.append("&client_id=\(CLIENT_ID)".data(using: .utf8)!)
        data.append("&client_secret=\(CLIENT_SECRET)".data(using: .utf8)!)
        data.append("&redirect_uri=\(REDIRECT_URL)".data(using: .utf8)!)
        data.append("&grant_type=authorization_code".data(using: .utf8)!)
        requestForGettingToken.httpBody = data
        requestForGettingToken.httpMethod = "POST"
        requestForGettingToken.timeoutInterval = 6
        
        print(String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Any)

        
        Alamofire.request(requestForGettingToken).responseJSON { (responseData) in
            if responseData.error == nil{
                var dataContainingTokens = JSON(responseData.data!)
                let accessToken = dataContainingTokens["access_token"].stringValue
                let refreshToken = dataContainingTokens["refresh_token"].stringValue
                let tokenType = dataContainingTokens["token_type"].stringValue
                
                print("****************************************************************************************")
                print("accessToken: \(accessToken)\nrefreshToken: \(refreshToken)")
                userValues.set(refreshToken, forKey: REFRESH_TOKEN)
                userValues.set(accessToken, forKey: ACCESS_TOKEN)
                userValues.set(tokenType, forKey: TOKEN_TYPE)
                
   //             self.changeLoadingLabel(lableToShowInLoading: "Loading . .")
                
                self.getTheUserValues(access_Token: accessToken, token_Type: tokenType)
                
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
    
    func getTheUserValues(access_Token accessToken: String, token_Type tokenType: String) -> Void {
        
        var requestForGettingUserDate = URLRequest(url: URL(string: USER_DETAILS_SCOPE_URL)!)
        requestForGettingUserDate.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
        requestForGettingUserDate.httpMethod = "GET"
        requestForGettingUserDate.timeoutInterval = 6
        
        Alamofire.request(requestForGettingUserDate).responseJSON { (responseData) in
            if responseData.error == nil {
                var dataContainingUserDetails = JSON(responseData.data!)
                print("****************************************************************************************")
                let firstName = dataContainingUserDetails["data"]["user"]["firstName"].stringValue
                let lastName = dataContainingUserDetails["data"]["user"]["lastName"].stringValue
                let emailId = dataContainingUserDetails["data"]["user"]["login"].stringValue
                print("****************************************************************************************")
                print("firstname: \(firstName)\nsecondname: \(lastName)\nemailId: \(emailId)")
                guard firstName != "" && lastName != "" && emailId != "" else {
                    let alert = UIAlertController(title: "Something went wrong!", message: "Try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                
                userValues.set(firstName + " " + lastName , forKey: USER_NAME)
                userValues.set(emailId, forKey: EMAIL_ID)
                userValues.set(true, forKey: USER_LOGGED_IN)
                
                
                
                let toTabBarViewControler = self.storyboard?.instantiateViewController(withIdentifier: "userTabBarViewController") as? UserPageTabController
                toTabBarViewControler?.userName = firstName + " " + lastName
                toTabBarViewControler?.emailId = emailId
                
                if let toTabBarViewControler = toTabBarViewControler {
                    //            self.changeLoadingLabel(lableToShowInLoading: "Loading . . .")
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.navigationController?.pushViewController(toTabBarViewControler, animated: true)
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

    func getTheAuthenticationCode(from url:URL?) -> String? {

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

// MARK:UINavigationControllerDelegate


// spinner view done in uiviewcontroller to provide the spinner to be available across all the view controller
// provided as a static method to be able to implement directly
// if you dont want this type of the view just add it to the view controller and use it for there itself

extension UIViewController {
    class func displaySpinner(onView : UIView, toDisplayString : String? = nil) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
         let displayLabel: UILabel = UILabel(frame: CGRect(x: spinnerView.bounds.midX, y: spinnerView.frame.midY, width: 350, height: 60))
        displayLabel.center = spinnerView.center
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

        if let displayText = toDisplayString {
            displayLabel.font = UIFont(name: "Avenir-Light", size: 35)
            displayLabel.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.8472549229)
            displayLabel.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.8472549229)
            displayLabel.textAlignment = .center
            displayLabel.text = displayText
            displayLabel.backgroundColor = UIColor.clear
        }
        
        
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = CGPoint(x: spinnerView.bounds.midX, y: spinnerView.bounds.midY + 60)
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            if let _ = toDisplayString {
                spinnerView.addSubview(displayLabel)
            }
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

