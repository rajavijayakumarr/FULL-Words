//
//  newWordViewController.swift
//  FULL Words
//
//  Created by User on 22/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MBProgressHUD
import Firebase

// All these are notification names that adds observer and will be posted using these string constants

let RESIZE_TABLEVIEWCELL = "CHANGE_TABLEVIEWCELL_LENGTH"
let POPUP_UP_KEYBOARD = "POPUP_UP_KEYBOARD"

class NewWordViewController: UIViewController {
    
    let newWOrdAdded = "newWordAddedForWOrds"
    let headingForTableViewCells = ["Enter Word", "Synonym", "Source"]
    static var userPressedCancel = false

    static var word: String? = ""
    static var meaning: String? = ""
    static var source: String? = ""
    
    @IBOutlet weak var addWordsTableView: UITableView!
    var activeTextField: UITextView?
    var userName: String?
    
    @IBOutlet weak var addButton: UIButton!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.layer.cornerRadius = 10
        addButton.clipsToBounds = true
        addButton.dropShadow(color: #colorLiteral(red: 0.9417235255, green: 0.7750624418, blue: 0.6908532977, alpha: 1), opacity: 1, radius: 4, offset: CGSize(width: 0, height: 4), maskToBounds: false)
        addWordsTableView.delegate = self
        addWordsTableView.dataSource = self
        addWordsTableView.rowHeight = UITableViewAutomaticDimension
        addWordsTableView.estimatedRowHeight = 100
        registerForAllNotification()
    }

    func registerForAllNotification() {
        // for keyboard popup and going down
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        // for other notifications
        NotificationCenter.default.addObserver(self, selector: #selector(changeTableHeight), name: NSNotification.Name(rawValue: RESIZE_TABLEVIEWCELL), object: nil)
    }
    @objc func keyboardWillBeHidden(_ aNotification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        addWordsTableView.contentInset = contentInsets
        addWordsTableView.scrollIndicatorInsets = contentInsets
    }
    @objc func keyboardWillBeShown(_ aNotification: NSNotification ) {
        let info = aNotification.userInfo
        let kbSize = (info![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (kbSize?.height)!, right: 0.0)
        addWordsTableView.contentInset = contentInsets
        addWordsTableView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= (kbSize?.height)!
        
        if aRect.contains((activeTextField?.frame.origin)!) {
            self.addWordsTableView.scrollRectToVisible((activeTextField?.frame)!, animated: true)
        }
    }
    
    @objc func changeTableHeight() {
        /* the begin updates and end updates is being declared for the tableview to stop jumping and returning when the bottom point exceeds
           to more than the maximum specified point */
        UIView.setAnimationsEnabled(false)
        addWordsTableView.beginUpdates()
        addWordsTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        addWordsTableView.scrollToRow(at: addWordsTableView.indexPath(for:addWordsTableView.visibleCells.last!)!, at: UITableViewScrollPosition.bottom, animated: true)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        NewWordViewController.userPressedCancel = false
        super.viewWillAppear(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NewWordViewController.word = ""
        NewWordViewController.source = ""
        NewWordViewController.meaning = ""
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        if NewWordViewController.userPressedCancel {
            let alert = UIAlertController(title: "Word not Saved", message: "Are you sure you want to close?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {_ in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func addButtonPressed(_ sender: UIButton) {
       
        removeBlankSpaceIfPresentAtPrefix(&NewWordViewController.word!)
        removeBlankSpaceIfPresentAtPrefix(&NewWordViewController.meaning!)
        removeBlankSpaceIfPresentAtPrefix(&NewWordViewController.source!)
        let title = "Missing fields" ; var messange = ""; var hasValue = true
        if NewWordViewController.word == "" {
            messange = "Word field is be blank!"
            hasValue = false
        }
        else if NewWordViewController.meaning == ""  {
            messange = "Meaning field is be blank!"
            hasValue = false
        }
        else if NewWordViewController.source == ""  {
            messange = "Source field is be blank!"
            hasValue = false
        }
        guard hasValue else {
            let alert = UIAlertController(title: title, message: messange, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.addWordToServer()
    }
    
    fileprivate func refreshTheAccessToken(_ word: String, _ meaning: String, _ source: String, _ spinnerView: MBProgressHUD) {
        print("this is sent if the access token is expired and refresh token is sent to refresh the access token")
        var urlRequestForToken = URLRequest(url: URL(string: TOKEN_URL)!)
        var data:Data = "refresh_token=\(userDefaultsObject.value(forKey: REFRESH_TOKEN) as? String ?? "token_revoked")".data(using: .utf8)!
        data.append("&client_id=\(CLIENT_ID)".data(using: .utf8)!)
        data.append("&client_secret=\(CLIENT_SECRET)".data(using: .utf8)!)
        data.append("&grant_type=refresh_token".data(using: .utf8)!)
        urlRequestForToken.httpBody = data
        urlRequestForToken.httpMethod = "POST"
        
        Alamofire.request(urlRequestForToken).responseJSON { (responseData) in
            if responseData.error == nil{
                print(responseData)
                var dataContainingTokens = JSON(responseData.data!)
                let accessToken = dataContainingTokens["access_token"].stringValue
                let tokenType = dataContainingTokens["token_type"].stringValue
                
                print("****************************************************************************************")
                print("accessToken: \(accessToken)\ntoken_type: \(tokenType)")
                userDefaultsObject.set(accessToken, forKey: ACCESS_TOKEN)
                userDefaultsObject.set(tokenType, forKey: TOKEN_TYPE)
                userDefaultsObject.set(true, forKey: IS_USER_LOGGED_IN)
                
                var urlRequests = URLRequest(url: URL(string: FULL_WORDS_API_URL)!)
                urlRequests.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer " + (userDefaultsObject.value(forKey: ACCESS_TOKEN) as? String)!]
                let dataToSend = ["word": word, "desc": meaning, "src": source]
                urlRequests.httpBody = try? JSONSerialization.data(withJSONObject: dataToSend, options: .prettyPrinted)
                urlRequests.httpMethod = "POST"
                urlRequests.timeoutInterval = 60
                
                Alamofire.request(urlRequests).responseJSON { (responseData) in
                    if responseData.error == nil {
                        let receivedWordValues = JSON(responseData.data!)
                        if receivedWordValues["response"].boolValue {
                            self.receiveAndSave(from: receivedWordValues, loadingScreen: spinnerView)
                        } else {
                            self.handleOtherErrors(fromData: receivedWordValues)
                        }
                    }
                }
            }
        }
    }
    
    func addWordToServer() {
        let spinnerView = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerView.label.text = "Adding Word..."
        
        let word = NewWordViewController.word
        let meaning = NewWordViewController.meaning
        let source = NewWordViewController.source
        
        var urlRequest = URLRequest(url: URL(string: FULL_WORDS_API_URL)!)
        urlRequest.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer " + (userDefaultsObject.value(forKey: ACCESS_TOKEN) as? String)!]
        let dataToSend = ["word": word, "desc": meaning, "src": source]
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: dataToSend, options: .prettyPrinted)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 60
        
        Alamofire.request(urlRequest).responseJSON { (responseData) in
            if responseData.error == nil {
                //                        let dataContainingUserDetails = JSON(responseData.data!)
                print("**************************************")
                print(String(data: responseData.data!, encoding: String.Encoding.utf8) as Any)
                let JSONdata = JSON(responseData.data!)
                if JSONdata["response"].boolValue {
                    self.receiveAndSave(from: JSONdata, loadingScreen: spinnerView)
                } else if JSONdata["error"].stringValue == "unauthorized_request" {
                    //responseJSON_Data["error"].stringValue == "unauthorized_request"
                    self.refreshTheAccessToken(word ?? "", meaning ?? "", source ?? "", spinnerView)
                } else {
                    self.handleOtherErrors(fromData: JSONdata)
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
    
    func handleOtherErrors(fromData receivedWordValues: JSON) {
        
        //firebase reports - word adding method failed
        if receivedWordValues["msg"].stringValue == "word already exists" {
            Analytics.logEvent("wordExists", parameters: nil)
        } else {
            Analytics.logEvent("wordAdded_failed", parameters: nil)

        }
        MBProgressHUD.hide(for: self.view, animated: true)
        let error = receivedWordValues["error"].stringValue
        let message = receivedWordValues["msg"].stringValue
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func receiveAndSave(from JSONdata: JSON, loadingScreen spinnerView: MBProgressHUD) {
        
        print("receiving and saving data....")
        let wordsDetails = WordDetails(context: PersistenceService.context)
        wordsDetails.dateUpdated = JSONdata["data"]["word"]["updatedAt"].doubleValue
        wordsDetails.dateAdded = JSONdata["data"]["word"]["createdAt"].doubleValue
        wordsDetails.wordAddedBy = self.userName
        wordsDetails.userId = JSONdata["data"]["word"]["userId"].stringValue
        wordsDetails.nameOfWord = JSONdata["data"]["word"]["word"].stringValue
        wordsDetails.meaningOfWord = JSONdata["data"]["word"]["desc"].stringValue
        wordsDetails.sourceOfWord = JSONdata["data"]["word"]["src"].stringValue
        PersistenceService.saveContext()
        spinnerView.label.text = "Adding Word..."
        self.updateTheFeedInAnywhereWorks(Word: JSONdata["data"]["word"]["word"].stringValue, Meaning: JSONdata["data"]["word"]["desc"].stringValue, Source: JSONdata["data"]["word"]["src"].stringValue)
        
        MBProgressHUD.hide(for: self.view, animated: true)
        
        //firebase reports - word adding method success
        Analytics.logEvent("wordAdded_success", parameters: nil)

        let alert = UIAlertController(title: "Success!", message: "Word added!", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
                let name = NSNotification.Name.init(self.newWOrdAdded)
                NotificationCenter.default.post(name: name, object: nil)
            })
        }
    }
    
    func updateTheFeedInAnywhereWorks(Word word: String, Meaning meaning: String, Source source: String) {
        let content = "Hey! Here is the new word I found. \n\n*Word*: \(word)\n*Meaning*: \(meaning)\n*Source*: \(source)\n#fullwords"
        
        var urlRequest = URLRequest(url: URL(string: FEEDS_URL)!)
        urlRequest.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer " + (userDefaultsObject.value(forKey: ACCESS_TOKEN) as? String)!]
        let dataToSend = ["content": content, "type": "update"]
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: dataToSend, options: .prettyPrinted)
        urlRequest.httpMethod = "POST"
        
        Alamofire.request(urlRequest).responseJSON { (responseData) in
            if responseData.error == nil {
                print(responseData as Any)
                
                //firebase reports - successfully posted AW feeds
                Analytics.logEvent("postedAWFeed", parameters: nil)
            } else {
                let alert = UIAlertController(title: "error", message: "cannot update feed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

/// extension used for text field related things
/// keyboard will vanish if touched on the screen
extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension NewWordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 0, tableView.tag == 1, tableView.tag == 2 {
            return UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headingForTableViewCells.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // to minimise the distance between two section in a tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch headingForTableViewCells[indexPath.row] {
        case "Enter Word":
            let wordCell =  addWordsTableView.dequeueReusableCell(withIdentifier: "wordsTableViewCells") as? WordTableViewCell
            wordCell?.headingLabel.text = "Enter Word"
            wordCell?.wordTextView.tag = 0
            activeTextField = wordCell?.wordTextView
            wordCell?.wordTextView.becomeFirstResponder()
            return wordCell ?? cell
            
        case "Synonym":
            let meaningCell =  addWordsTableView.dequeueReusableCell(withIdentifier: "wordsTableViewCells") as? WordTableViewCell
            meaningCell?.headingLabel.text = "Synonym"
            meaningCell?.wordTextView.tag = 1
            activeTextField = meaningCell?.wordTextView
            meaningCell?.wordTextView.returnKeyType = UIReturnKeyType.default
            return meaningCell ?? cell

        case "Source":
            let sourceCell =  addWordsTableView.dequeueReusableCell(withIdentifier: "wordsTableViewCells") as? WordTableViewCell
            sourceCell?.headingLabel.text = "Source"
            sourceCell?.wordTextView.tag = 2
            activeTextField = sourceCell?.wordTextView
            sourceCell?.wordTextView.returnKeyType = UIReturnKeyType.default
            return sourceCell ?? cell

        default:
            break
        }
      return cell
    }
}

// for the uitextview to display in the storyboard
extension NewWordViewController {
    
    //function to remove the meaning if it contains only speces in prefixes
    func removeBlankSpaceIfPresentAtPrefix(_ string: inout String) {
        while string.hasPrefix(" ") || string.hasPrefix("\n") {
            string.removeFirst()
        }
    }
}
class WordTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var wordTextView: UITextView!
    @IBOutlet weak var headingLabel: UILabel!
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        headingLabel.textColor = #colorLiteral(red: 0.1026113406, green: 0.194866389, blue: 0.3516743779, alpha: 0.8032427226)
        if textView.text == "Type here" {
            textView.text = ""
        }
        textView.textColor = #colorLiteral(red: 0.1026113406, green: 0.194866389, blue: 0.3516743779, alpha: 0.8032427226)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        headingLabel.textColor = #colorLiteral(red: 0.1026113406, green: 0.194866389, blue: 0.3516743779, alpha: 0.5)
        if textView.text == "" {
            textView.text = "Type here"
            textView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.tag == 0 {
            if text == "\n" {
               return false
            }
        }
        return true
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 0{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: RESIZE_TABLEVIEWCELL), object: nil)
            NewWordViewController.word = wordTextView.text
            if !(textView.text == "") {
                NewWordViewController.userPressedCancel = true
            } else {
                NewWordViewController.userPressedCancel = false
            }
        } else if textView.tag == 1 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: RESIZE_TABLEVIEWCELL), object: nil)
            NewWordViewController.meaning = wordTextView.text
            if !(textView.text == "") {
                NewWordViewController.userPressedCancel = true
            } else {
                NewWordViewController.userPressedCancel = false
            }
        } else if textView.tag == 2{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: RESIZE_TABLEVIEWCELL), object: nil)
            NewWordViewController.source = wordTextView.text
        }
    }
}

