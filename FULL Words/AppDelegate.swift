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
import MBProgressHUD
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    var viewController: UserPageTabController?


    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
            if userValues.bool(forKey: USER_LOGGED_IN) {
            let accessToken = userValues.value(forKey: ACCESS_TOKEN) as! String
            let tokenType = userValues.value(forKey: TOKEN_TYPE) as! String
            
            _ = self.getTheUserValues(access_Token: accessToken, token_Type: tokenType)
            //before this all the receiving and sending occurs and use befoer this to implement the loading screen
            //this is where the new view controller will be displayed
            
            viewController = UserPageTabController()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            viewController = storyBoard.instantiateViewController(withIdentifier: "userTabBarViewController") as? UserPageTabController
            viewController?.userName = userValues.value(forKey: USER_NAME) as? String
            viewController?.emailId = userValues.value(forKey: EMAIL_ID) as? String
            viewController?.userLoggedIn = false
            if let viewController = viewController {
                let newNavigationController = CustomNavigationController()
                let greenColor =  #colorLiteral(red: 0.344810009, green: 0.7177901864, blue: 0.6215276122, alpha: 1)
                newNavigationController.navigationBar.backgroundColor = greenColor
                newNavigationController.navigationBar.barTintColor = greenColor
                newNavigationController.navigationBar.isTranslucent = false
                newNavigationController.viewControllers = [viewController]
                newNavigationController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) as Any]
                newNavigationController.navigationBar.backItem?.backBarButtonItem?.style = UIBarButtonItemStyle.plain
                newNavigationController.view.tintColor = #colorLiteral(red: 0.2419127524, green: 0.6450607777, blue: 0.9349957108, alpha: 1)
                self.window?.rootViewController = newNavigationController
                self.window?.makeKeyAndVisible()
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
    
    func refreshingAccessToken(access_token accessToken: String, token_Type tokenType: String) {
        print("This is most important and it is the function that is responsible for refreshing the access token")
        var requestForGettingToken = URLRequest(url: URL(string: TOKEN_URL)!)
        var data:Data = "refresh_token=\(userValues.value(forKey: REFRESH_TOKEN) as? String ?? "token_revoked")".data(using: .utf8)!
        data.append("&client_id=\(CLIENT_ID)".data(using: .utf8)!)
        data.append("&client_secret=\(CLIENT_SECRET)".data(using: .utf8)!)
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
                userValues.set(accessToken, forKey: ACCESS_TOKEN)
                userValues.set(tokenType, forKey: TOKEN_TYPE)
                userValues.set(true, forKey: USER_LOGGED_IN)
                
                var requestForGettingUserDate = URLRequest(url: URL(string: USER_DETAILS_SCOPE_URL)!)
                requestForGettingUserDate.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
                requestForGettingUserDate.httpMethod = "GET"
                
                Alamofire.request(requestForGettingUserDate).responseJSON { (responseData) in
                    if responseData.error == nil {
                        
                        var dataContainingUserDetails = JSON(responseData.data!)
                        guard dataContainingUserDetails["ok"].boolValue else {
                            let error = dataContainingUserDetails["error"].stringValue
                            let message = dataContainingUserDetails["msg"].stringValue
                            print(error + ":" + message)
                            return
                        }
                        print("************************************************************************************")
                        let firstName = dataContainingUserDetails["data"]["user"]["firstName"].stringValue
                        let lastName = dataContainingUserDetails["data"]["user"]["lastName"].stringValue
                        let emailId = dataContainingUserDetails["data"]["user"]["login"].stringValue
                        print("************************************************************************************")
                        print("firstname: \(firstName)\nsecondname: \(lastName)\nemailId: \(emailId)")
                        print("\(dataContainingUserDetails["data"]["user"]["id"].stringValue)")
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
    }
    
    func getTheUserValues(access_Token accessToken: String, token_Type tokenType: String) -> Bool {
        
        var successInGettingValues = true
        
        var requestForGettingUserDate = URLRequest(url: URL(string: USER_DETAILS_SCOPE_URL)!)
        requestForGettingUserDate.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
        requestForGettingUserDate.httpMethod = "GET"
        
        Alamofire.request(requestForGettingUserDate).responseJSON { (responseData) in
            if responseData.error == nil {
                
                var dataContainingUserDetails = JSON(responseData.data!)
                guard dataContainingUserDetails["ok"].boolValue else {
                    successInGettingValues = false
                    print("access token revoked refreshing...")
                    self.refreshingAccessToken(access_token: accessToken, token_Type: tokenType)
                    return
                }
                print("****************************************************************************************")
                let firstName = dataContainingUserDetails["data"]["user"]["firstName"].stringValue
                let lastName = dataContainingUserDetails["data"]["user"]["lastName"].stringValue
                let emailId = dataContainingUserDetails["data"]["user"]["login"].stringValue
                print("****************************************************************************************")
                print("firstname: \(firstName)\nsecondname: \(lastName)\nemailId: \(emailId)")
                print("\(dataContainingUserDetails["data"]["user"]["id"].stringValue)")
                guard firstName != "" && emailId != "" else {
                    return
                }
                
                userValues.set(firstName + " " + (lastName != "" ? lastName:"") , forKey: USER_NAME)
                userValues.set(emailId, forKey: EMAIL_ID)
                userValues.set(true, forKey: USER_LOGGED_IN)
                successInGettingValues = true
            } else {
                print("something went wrong refreshing access token")
                self.refreshingAccessToken(access_token: accessToken, token_Type: tokenType)
            }
        }
        return successInGettingValues
    }
}

