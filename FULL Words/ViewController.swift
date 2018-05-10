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

let ADAPTIVEU_CLIENT_ID = "29354-dad2dd8a5dda745be5e6faea2a155d77"
let ADAPTIVEU_CLIENT_SECRET = "iOsdmGZj-8Tydm0sJ8l6N6dWCZ_e0uZQ5LTy2KfT"
let ADAPTIVEU_REDIRECT_URL = "com.FULL.FULL-Words://"
let ADAPTIVEU_CODE_URL = "https://access.anywhereworks.com/o/oauth2/auth"
let ADAPTIVEU_TOKEN_URL = "https://access.anywhereworks.com/o/oauth2/v1/token"

let ADAPTIVEU_SCOPE_URL = "https://api.anywhereworks.com/api/v1/user/me"
let ADAPTIVEU_WORDS_SCOPE_URL = "https://full-learn.appspot.com/api/v1/words"

let ADAPTIVIEWU_REFRESH_TOKEN = "ADAPTIVIEWU_REFRESH_TOKEN"
let ADAPTIVIEWU_ACCESS_TOKEN = "ADAPTIVIEWU_ACCESS_TOKEN"
let ADAPTIVIEWU_TOKEN_TYPE = "ADAPTIVIEWU_TOKEN_TYPE"
let UNIQUE_STATE_TOKEN_VERIFY = "validated_token"
let USER_LOGGED_IN = "USER_LOGGED_IN"
let userValues = UserDefaults.standard

let USER_NAME = "USER_NAME"
let EMAIL_ID = "EMAIL_ID"
let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class ViewController: UIViewController, UIScrollViewDelegate, SFSafariViewControllerDelegate {
    
    var authenticationSession: SFAuthenticationSession? = nil
    var safariViewController: SFSafariViewController? = nil


    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet var loadingVIew: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let name = NSNotification.Name.init(rawValue: kCloseSafariViewControllerNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(self.safariLogin(notification:)), name: name, object: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func loginWithAdaptvantButtonClicked(_ sender: UIButton) {
        let url = ADAPTIVEU_CODE_URL+"?response_type=code&client_id="+ADAPTIVEU_CLIENT_ID+"&access_type=offline&scope=awapis.identity+awapis.feeds.write&redirect_uri="+ADAPTIVEU_REDIRECT_URL+"&approval_prompt=force"
        
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
        self.showLoadingView()
        print(url?.absoluteString ?? "nothing")
        print(authenticationCode!)
        
        var requestForGettingToken = URLRequest(url: URL(string: ADAPTIVEU_TOKEN_URL)!)
        self.changeLoadingLabel(lableToShowInLoading: "sending token request")
        
        var data:Data = "code=\(authenticationCode ?? "none")".data(using: .utf8)!
        data.append("&client_id=\(ADAPTIVEU_CLIENT_ID)".data(using: .utf8)!)
        data.append("&client_secret=\(ADAPTIVEU_CLIENT_SECRET)".data(using: .utf8)!)
        data.append("&redirect_uri=\(ADAPTIVEU_REDIRECT_URL)".data(using: .utf8)!)
        data.append("&grant_type=authorization_code".data(using: .utf8)!)
        requestForGettingToken.httpBody = data
        requestForGettingToken.httpMethod = "POST"
        
        print(String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Any)
        
        Alamofire.request(requestForGettingToken).responseJSON { (responseData) in
            if responseData.error == nil{
                var dataContainingTokens = JSON(responseData.data!)
                let accessToken = dataContainingTokens["access_token"].stringValue
                let refreshToken = dataContainingTokens["refresh_token"].stringValue
                let tokenType = dataContainingTokens["token_type"].stringValue
                
                print("****************************************************************************************")
                print("accessToken: \(accessToken)\nrefreshToken: \(refreshToken)")
                userValues.set(refreshToken, forKey: ADAPTIVIEWU_REFRESH_TOKEN)
                userValues.set(accessToken, forKey: ADAPTIVIEWU_ACCESS_TOKEN)
                userValues.set(tokenType, forKey: ADAPTIVIEWU_TOKEN_TYPE)
                
                self.changeLoadingLabel(lableToShowInLoading: "tokens received")
                
                self.getTheUserValues(access_Token: accessToken, token_Type: tokenType, request_For_Getting_Token: requestForGettingToken)
                
            }
        }
        self.safariViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    func getTheUserValues(access_Token accessToken: String, token_Type tokenType: String, request_For_Getting_Token requestForGettingTokens: URLRequest) -> Void {
        
        var requestForGettingToken = requestForGettingTokens
        
        var requestForGettingUserDate = URLRequest(url: URL(string: ADAPTIVEU_SCOPE_URL)!)
        requestForGettingUserDate.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
        requestForGettingToken.httpMethod = "GET"
        
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
                
                self.changeLoadingLabel(lableToShowInLoading: "retrived user values")
                
                userValues.set(firstName + " " + lastName , forKey: USER_NAME)
                userValues.set(emailId, forKey: EMAIL_ID)
                userValues.set(true, forKey: USER_LOGGED_IN)
                
                
                
                let toTabBarViewControler = self.storyboard?.instantiateViewController(withIdentifier: "userTabBarViewController") as? UserPageTabController
                toTabBarViewControler?.userName = firstName + " " + lastName
                toTabBarViewControler?.emailId = emailId
                if let toTabBarViewControler = toTabBarViewControler {
                    self.navigationController?.pushViewController(toTabBarViewControler, animated: true)
                }
            }
        }
    }
    func showLoadingView() {
        loadingVIew.bounds.size.width = view.bounds.width
        loadingVIew.bounds.size.height = view.bounds.height
        
        loadingVIew.center = view.center
        view.addSubview(loadingVIew)
    }
    func changeLoadingLabel(lableToShowInLoading lable: String) {
        loadingLabel.text = lable
    }
    func hideLoadingView() {
        loadingVIew.removeFromSuperview()
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

