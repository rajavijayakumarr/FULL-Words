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

let ADAPTIVIEWU_REFRESH_TOKEN = "ADAPTIVIEWU_REFRESH_TOKEN"
let ADAPTIVIEWU_ACCESS_TOKEN = "ADAPTIVIEWU_ACCESS_TOKEN"

let UNIQUE_STATE_TOKEN_VERIFY = "validated_token"


class ViewController: UIViewController, UIScrollViewDelegate {
    
    var authenticationSession: SFAuthenticationSession? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        let url = ADAPTIVEU_CODE_URL+"?response_type=code&client_id="+ADAPTIVEU_CLIENT_ID+"&access_type=offline&scope=awapis.identity&redirect_uri="+ADAPTIVEU_REDIRECT_URL+"&approval_prompt=force&state="+UNIQUE_STATE_TOKEN_VERIFY
        authenticationSession = SFAuthenticationSession(url: URL(string: url)!, callbackURLScheme: ADAPTIVEU_REDIRECT_URL, completionHandler: { (receivedURL, error) in
            let authenticationCode = self.getTheAuthenticationCode(from: receivedURL)
            print(receivedURL?.absoluteString ?? "nothing")
            print(authenticationCode)
            
            var request = URLRequest(url: URL(string: ADAPTIVEU_TOKEN_URL)!)
            request.setValue("https://access.anywhereworks.com", forHTTPHeaderField: "Host")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            var data:Data = "code=\(authenticationCode)".data(using: .utf8)!
            data.append("&client_id=\(ADAPTIVEU_CLIENT_ID)".data(using: .utf8)!)
            data.append("&client_secret=\(ADAPTIVEU_CLIENT_SECRET)".data(using: .utf8)!)
            data.append("&redirect_uri=\(ADAPTIVEU_REDIRECT_URL)".data(using: .utf8)!)
            data.append("&grant_type=authorization_code".data(using: .utf8)!)
            request.httpBody = data
            request.httpMethod = "POST"
            
            print(String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Any)


            Alamofire.request(URL(string: ADAPTIVEU_TOKEN_URL)!).responseJSON { (responseData) in
                print(NSString(data: responseData.data! , encoding: String.Encoding.utf8.rawValue) as Any)
            }
            
//            let headers = ["Host":"https://access.anywhereworks.com",
//                           "Content-Type":"application/x-www-form-urlencoded"]
//            let parameters = ["grant_type": "authorization_code",
//                              "client_id": ADAPTIVEU_CLIENT_ID,
//                              "redirect_uri": ADAPTIVEU_REDIRECT_URL,
//                              "code": String(authenticationCode)]
//
//            Alamofire.request(URL(string: ADAPTIVEU_TOKEN_URL)!, method:.post, parameters:parameters, headers:headers).validate(contentType: ["application/json"]).responseJSON { response in
//                switch response.result {
//                case .success:
//                    debugPrint(response)
//
//                case .failure(let error):
//                    print(error)
//                }
//
//            }

            
        })
    }

    @IBAction func loginWithAdaptvantButtonClicked(_ sender: UIButton) {
        authenticationSession?.start()
    }
    
    func getTheAuthenticationCode(from url:URL?) -> String {
        guard let url = url else {
            return "no url found"
        }
        let stringUrl:String! = url.absoluteString
        let index = stringUrl?.index(after: stringUrl?.index(of: "=") ?? (stringUrl?.startIndex)!)
        let substring = stringUrl[index!...]
        let anotherIndex = substring.index(before: substring.index(of: "&")!)
        let substringOfUrl = stringUrl[index!...anotherIndex]
        return String(substringOfUrl)
    }
    
}

