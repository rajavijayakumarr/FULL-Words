//
//  AppDelegate.swift
//  FULL Words
//
//  Created by User on 18/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    var viewController: userPageTabController?


    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        if userValues.bool(forKey: USER_LOGGED_IN) {
            
            
        viewController = userPageTabController()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            viewController = storyBoard.instantiateViewController(withIdentifier: "userTabBarViewController") as? userPageTabController
            viewController?.userName = userValues.value(forKey: USER_NAME) as? String
            viewController?.emailId = userValues.value(forKey: EMAIL_ID) as? String
            if let viewController = viewController {
                let newNavigationController = UINavigationController()
                newNavigationController.navigationBar.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                newNavigationController.navigationBar.barTintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                newNavigationController.viewControllers = [viewController]
                self.window?.rootViewController = newNavigationController
                self.window?.makeKeyAndVisible()
            }
            
            
            
        var requestForGettingToken = URLRequest(url: URL(string: ADAPTIVEU_TOKEN_URL)!)
        
        var data:Data = "refresh_token=\(userValues.value(forKey: ADAPTIVIEWU_REFRESH_TOKEN) as? String ?? "token_revoked")".data(using: .utf8)!
        data.append("&client_id=\(ADAPTIVEU_CLIENT_ID)".data(using: .utf8)!)
        data.append("&client_secret=\(ADAPTIVEU_CLIENT_SECRET)".data(using: .utf8)!)
        data.append("&grant_type=refresh_token".data(using: .utf8)!)
        requestForGettingToken.httpBody = data
        requestForGettingToken.httpMethod = "POST"
        
        Alamofire.request(requestForGettingToken).responseJSON { (responseData) in
            if responseData.error == nil{
                print(responseData)
                var dataContainingTokens = JSON(responseData.data!)
                let accessToken = dataContainingTokens["access_token"].stringValue
                let tokenType = dataContainingTokens["token_type"].stringValue
                
                print("****************************************************************************************")
                print("accessToken: \(accessToken)\ntoken_type: \(tokenType)")
                userValues.set(accessToken, forKey: ADAPTIVIEWU_ACCESS_TOKEN)
                userValues.set(tokenType, forKey: ADAPTIVIEWU_TOKEN_TYPE)
                userValues.set(true, forKey: USER_LOGGED_IN)
                
                var requestForGettingUserDate = URLRequest(url: URL(string: ADAPTIVEU_SCOPE_URL)!)
                requestForGettingUserDate.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
                requestForGettingToken.httpMethod = "GET"
                self.getTheUserValues(access_Token: accessToken, token_Type: tokenType, request_For_Getting_Token: requestForGettingToken)
                
            }
        }
        
    }
        return true
}
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        PersistenceService.saveContext()
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // just making sure we send the notification when the URL is opened in SFSafariViewController
        if let sourceApplication = options[.sourceApplication] {
            print("app delegate called", sourceApplication as Any)
            if (sourceApplication as? String == "com.apple.SafariViewService") {
                //   NSNotificationCenter.defaultCenter().postNotificationName(kCloseSafariViewControllerNotification, object: url)
                let name = NSNotification.Name.init(kCloseSafariViewControllerNotification)
                NotificationCenter.default.post(name: name, object: url)
                return true
            }
        }
        return true
    }
    
    //for autologin
    
    
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
                    return
                }
                
                
                userValues.set(firstName + " " + lastName , forKey: USER_NAME)
                userValues.set(emailId, forKey: EMAIL_ID)
                userValues.set(true, forKey: USER_LOGGED_IN)

               
            }
        }
    }

   

}

