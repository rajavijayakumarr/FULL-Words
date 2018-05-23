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

let SAVE_BUTTON_PRESSED = "SAVE_BUTTON_PRESSED"
let SAVE_BUTTON_INVALIDATE = "SAVE_BUTTON_INVALIDATE"

let CHANGE_TABLEVIEWCELL_LENGTH = "CHANGE_TABLEVIEWCELL_LENGTH"
let POPUP_UP_KEYBOARD = "POPUP_UP_KEYBOARD"

// this is just an example commit i made to check for the merge request

class NewWordViewController: UIViewController {
    

    let newWOrdAdded = "newWordAddedForWOrds"
    let headingForTableViewCells = ["Word", "Meaning", "Source"]
    static var ifUserPressedCancelAfterGivingWOrdValues = false

    static var nameOfTheWord: String? = ""
    static var meaningOfTheWord: String? = ""
    static var sourceOfTheWord: String? = ""
    
    @IBOutlet weak var addWordsTableView: UITableView!
    var activeTextField: UITextView?
    var userName: String?
    
    @IBOutlet weak var navigationBarX: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    var saveBarButtonPressed: UIBarButtonItem!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.hideKeyboardWhenTappedAround()
        addWordsTableView.delegate = self
        addWordsTableView.dataSource = self
        addWordsTableView.rowHeight = UITableViewAutomaticDimension
        addWordsTableView.estimatedRowHeight = 100
        saveBarButtonPressed = UIBarButtonItem(title: "Add",style: .plain, target: self, action: #selector(saveButtonPressed(_:)))
        saveBarButtonPressed.tintColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        self.navigationBarItem.setRightBarButton(saveBarButtonPressed, animated: true)
//        saveBarButtonPressed.isEnabled = false
        registerForKeyboardNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(changeTableHeight), name: NSNotification.Name(rawValue: CHANGE_TABLEVIEWCELL_LENGTH), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveButtonValidated), name: NSNotification.Name(rawValue: SAVE_BUTTON_PRESSED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveButtonInvalidated), name: NSNotification.Name(rawValue: SAVE_BUTTON_INVALIDATE), object: nil)
    }

    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
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
        // the begin updates and end updates is being declared for the tableview to stop jumping and returning when the bottom point exceeds
        // to more than the maximum specified point
        UIView.setAnimationsEnabled(false)
        addWordsTableView.beginUpdates()
        addWordsTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        addWordsTableView.scrollToRow(at: addWordsTableView.indexPath(for:addWordsTableView.visibleCells.last!)!, at: UITableViewScrollPosition.bottom, animated: true)
    }
    @objc func saveButtonValidated() {
        saveBarButtonPressed.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        saveBarButtonPressed.isEnabled = true
        
    }
    @objc func saveButtonInvalidated() {
        saveBarButtonPressed.tintColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
//        saveBarButtonPressed.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        NewWordViewController.ifUserPressedCancelAfterGivingWOrdValues = false
        super.viewWillAppear(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NewWordViewController.nameOfTheWord = ""
        NewWordViewController.sourceOfTheWord = ""
        NewWordViewController.meaningOfTheWord = ""
        saveBarButtonPressed = nil
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        if NewWordViewController.ifUserPressedCancelAfterGivingWOrdValues {
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
    @objc func saveButtonPressed(_ sender: UIBarButtonItem) {
        removeBlankSpaceIfPresentAtPrefix(&NewWordViewController.nameOfTheWord!)
        removeBlankSpaceIfPresentAtPrefix(&NewWordViewController.meaningOfTheWord!)
        removeBlankSpaceIfPresentAtPrefix(&NewWordViewController.sourceOfTheWord!)
        let title = "Missing fields" ; var messange = ""; var hasValue = true
        if NewWordViewController.nameOfTheWord == "" {
            messange = "Word field is be blank!"
            hasValue = false
        }
        else if NewWordViewController.meaningOfTheWord == ""  {
            messange = "Meaning field is be blank!"
            hasValue = false
        }
        else if NewWordViewController.sourceOfTheWord == ""  {
            messange = "Source field is be blank!"
            hasValue = false
        }
        guard hasValue else {
            let alert = UIAlertController(title: title, message: messange, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let spinnerView = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerView.label.text = "UploadingWord"
        
        let addedWord = NewWordViewController.nameOfTheWord
        let wordMeaning = NewWordViewController.meaningOfTheWord
        let sourceOfTheWord = NewWordViewController.sourceOfTheWord
        
        var requestForPostingWord = URLRequest(url: URL(string: FULL_WORDS_SCOPE_URL)!)
        requestForPostingWord.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer " + (userValues.value(forKey: ACCESS_TOKEN) as? String)!]
        let dataToSend = ["word": addedWord, "desc": wordMeaning, "src": sourceOfTheWord]
        requestForPostingWord.httpBody = try? JSONSerialization.data(withJSONObject: dataToSend, options: .prettyPrinted)
        requestForPostingWord.httpMethod = "POST"
        requestForPostingWord.timeoutInterval = 60
        
                Alamofire.request(requestForPostingWord).responseJSON { (responseData) in
                    if responseData.error == nil {
//                        let dataContainingUserDetails = JSON(responseData.data!)
                        print("**************************************")
                        print(String(data: responseData.data!, encoding: String.Encoding.utf8) as Any)
                        let receivedWordValues = JSON(responseData.data!)
                        if receivedWordValues["response"].boolValue {
                            self.receiveAndSave(from: receivedWordValues, loadingScreen: spinnerView)
                        } else if receivedWordValues["error"].stringValue == "unauthorized_request" {
                            
                            print("this is sent if the access token is expired and refresh token is sent to refresh the access token")
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
                                    
                                    Alamofire.request(requestForPostingWord).responseJSON { (responseData) in
                                        if responseData.error != nil {
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
                        } else {
                            self.handleOtherErrors(fromData: receivedWordValues)
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
        MBProgressHUD.hide(for: self.view, animated: true)
        let error = receivedWordValues["error"].stringValue
        let message = receivedWordValues["msg"].stringValue
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func receiveAndSave(from receivedWordValues: JSON, loadingScreen spinnerView: MBProgressHUD) {
        
        let wordsDetails = WordDetails(context: PersistenceService.context)
        wordsDetails.dateUpdated = receivedWordValues["data"]["word"]["updatedAt"].doubleValue
        wordsDetails.dateAdded = receivedWordValues["data"]["word"]["createdAt"].doubleValue
        wordsDetails.wordAddedBy = self.userName
        wordsDetails.userId = receivedWordValues["data"]["word"]["userId"].stringValue
        wordsDetails.nameOfWord = receivedWordValues["data"]["word"]["word"].stringValue
        wordsDetails.meaningOfWord = receivedWordValues["data"]["word"]["desc"].stringValue
        wordsDetails.sourceOfWord = receivedWordValues["data"]["word"]["src"].stringValue
        PersistenceService.saveContext()
        spinnerView.label.text = "Adding Word..."
        self.updateTheFeedInAnywhereWorks(Word: receivedWordValues["data"]["word"]["word"].stringValue, Meaning: receivedWordValues["data"]["word"]["desc"].stringValue, Source: receivedWordValues["data"]["word"]["src"].stringValue)
        
        MBProgressHUD.hide(for: self.view, animated: true)
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
        
        var requestForPostingFeed = URLRequest(url: URL(string: FEEDS_SCOPE_URL)!)
        requestForPostingFeed.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer " + (userValues.value(forKey: ACCESS_TOKEN) as? String)!]
        let dataToSend = ["content": content, "type": "update"]
        requestForPostingFeed.httpBody = try? JSONSerialization.data(withJSONObject: dataToSend, options: .prettyPrinted)
        requestForPostingFeed.httpMethod = "POST"
        
        Alamofire.request(requestForPostingFeed).responseJSON { (responseData) in
            if responseData.error == nil {
                print(responseData as Any)
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
    
    ///////////////////// to minimise the distance between two section in a tableview
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
    /////////////////////
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch headingForTableViewCells[indexPath.row] {
        case "Word":
            let wordCell =  addWordsTableView.dequeueReusableCell(withIdentifier: "wordsTableViewCells") as? WordTableViewCell
            wordCell?.headingLabel.text = "Word"
            wordCell?.wordTextView.tag = 0
            activeTextField = wordCell?.wordTextView
            wordCell?.wordTextView.becomeFirstResponder()
            return wordCell ?? cell
            
        case "Meaning":
            let meaningCell =  addWordsTableView.dequeueReusableCell(withIdentifier: "wordsTableViewCells") as? WordTableViewCell
            meaningCell?.headingLabel.text = "Meaning"
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
    
    static func chechAndEnableAddButton() {
        
        guard NewWordViewController.nameOfTheWord != "", NewWordViewController.meaningOfTheWord != "", NewWordViewController.sourceOfTheWord != "" else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SAVE_BUTTON_INVALIDATE), object: nil)
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SAVE_BUTTON_PRESSED), object: nil)
    }
    
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
        
        if textView.text == "Type here" {
            textView.text = ""
        }
        textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    func textViewDidEndEditing(_ textView: UITextView) {

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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CHANGE_TABLEVIEWCELL_LENGTH), object: nil)
            NewWordViewController.nameOfTheWord = wordTextView.text
            if !(textView.text == "") {
                NewWordViewController.ifUserPressedCancelAfterGivingWOrdValues = true
            } else {
                NewWordViewController.ifUserPressedCancelAfterGivingWOrdValues = false
            }
        } else if textView.tag == 1 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CHANGE_TABLEVIEWCELL_LENGTH), object: nil)
            NewWordViewController.meaningOfTheWord = wordTextView.text
            if !(textView.text == "") {
                NewWordViewController.ifUserPressedCancelAfterGivingWOrdValues = true
            } else {
                NewWordViewController.ifUserPressedCancelAfterGivingWOrdValues = false
            }
        } else if textView.tag == 2{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CHANGE_TABLEVIEWCELL_LENGTH), object: nil)
            NewWordViewController.sourceOfTheWord = wordTextView.text
        }
        NewWordViewController.chechAndEnableAddButton()
    }
}

