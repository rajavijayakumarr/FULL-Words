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

let ADAPTIVIEWU_REFRESH_TOKEN = "ADAPTIVIEWU_REFRESH_TOKEN"
let ADAPTIVIEWU_ACCESS_TOKEN = "ADAPTIVIEWU_ACCESS_TOKEN"
let ADAPTIVIEWU_TOKEN_TYPE = "ADAPTIVIEWU_TOKEN_TYPE"
let UNIQUE_STATE_TOKEN_VERIFY = "validated_token"
let userValues = UserDefaults.standard

let USER_NAME = "USER_NAME"
let EMAIL_ID = "EMAIL_ID"

class ViewController: UIViewController, UIScrollViewDelegate {
    
    var authenticationSession: SFAuthenticationSession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBAction func loginWithAdaptvantButtonClicked(_ sender: UIButton) {
        let url = ADAPTIVEU_CODE_URL+"?response_type=code&client_id="+ADAPTIVEU_CLIENT_ID+"&access_type=offline&scope=awapis.identity&redirect_uri="+ADAPTIVEU_REDIRECT_URL+"&approval_prompt=force"
        authenticationSession = SFAuthenticationSession(url: URL(string: url)!, callbackURLScheme: ADAPTIVEU_REDIRECT_URL, completionHandler: { (receivedURL, error) in
            
            guard error == nil else {
                let alert = UIAlertController(title: "error", message: "press ok", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let authenticationCode = self.getTheAuthenticationCode(from: receivedURL)
            
            guard authenticationCode != nil || authenticationCode == "access_denied" else {
                let alert = UIAlertController(title: "User cancelled", message: "Try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            print(receivedURL?.absoluteString ?? "nothing")
            print(authenticationCode!)
            
            var requestForGettingToken = URLRequest(url: URL(string: ADAPTIVEU_TOKEN_URL)!)
            
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
                            
                            userValues.set(firstName + " " + lastName , forKey: USER_NAME)
                            userValues.set(emailId, forKey: EMAIL_ID)
                            let toTabBarViewControler = self.storyboard?.instantiateViewController(withIdentifier: "userTabBarViewController") as? userPageTabController
                            toTabBarViewControler?.userName = firstName + " " + lastName
                            toTabBarViewControler?.emailId = emailId
                            if let toTabBarViewControler = toTabBarViewControler {
                                self.navigationController?.pushViewController(toTabBarViewControler, animated: true)
                            }
                            
                        }
                    }
                }
            }
        })
        authenticationSession?.start()
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

