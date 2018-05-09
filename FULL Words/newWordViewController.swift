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

let SAVE_BUTTON_PRESSED = "SAVE_BUTTON_PRESSED"
let SAVE_BUTTON_INVALIDATE = "SAVE_BUTTON_INVALIDATE"

class newWordViewController: UIViewController {
    
    let newWOrdAdded = "newWordAddedForWOrds"
    let headingForTableViewCells = ["Word:", "Meaning:", "Source:"]

    
    static var nameOfTheWord: String? = ""
    static var meaningOfTheWord: String? = ""
    static var sourceOfTheWord: String? = ""
    
    @IBOutlet weak var addWordsTableView: UITableView!
    var activeTextField: UITextField?
    var userName: String?
    
    @IBOutlet weak var navigationBarX: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet var scrollView: UIScrollView!
    
    var saveBarButtonPressed: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.scrollView.delegate = self
        addWordsTableView.delegate = self
        addWordsTableView.dataSource = self
        addWordsTableView.rowHeight = UITableViewAutomaticDimension
        addWordsTableView.estimatedRowHeight = 100
        
        saveBarButtonPressed = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed(_:)))
        saveBarButtonPressed.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        self.navigationBarItem.setRightBarButton(saveBarButtonPressed, animated: true)
        saveBarButtonPressed.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(saveButtonValidated), name: NSNotification.Name(rawValue: SAVE_BUTTON_PRESSED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveButtonInvalidated), name: NSNotification.Name(rawValue: SAVE_BUTTON_INVALIDATE), object: nil)
    }
    @objc func saveButtonValidated() {
        saveBarButtonPressed.tintColor = UIColor.blue
        saveBarButtonPressed.isEnabled = true
    }
    @objc func saveButtonInvalidated() {
        saveBarButtonPressed.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        saveBarButtonPressed.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        newWordViewController.nameOfTheWord = ""
        newWordViewController.sourceOfTheWord = ""
        newWordViewController.meaningOfTheWord = ""
        saveBarButtonPressed = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
                self.dismiss(animated: true, completion: nil)
    }
    @objc func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        let addedWord = newWordViewController.nameOfTheWord
        let wordMeaning = newWordViewController.meaningOfTheWord
        let sourceOfTheWord = newWordViewController.sourceOfTheWord
        
        var requestForPostingWord = URLRequest(url: URL(string: ADAPTIVEU_WORDS_SCOPE_URL)!)
        requestForPostingWord.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestForPostingWord.setValue("Bearer " + (userValues.value(forKey: ADAPTIVIEWU_ACCESS_TOKEN) as? String)!, forHTTPHeaderField: "Authorization")

        requestForPostingWord.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer " + (userValues.value(forKey: ADAPTIVIEWU_ACCESS_TOKEN) as? String)!]
        let dataToSend = JSON("{\"word\":\"\(addedWord ?? "")\", \"desc\":\"\(wordMeaning ?? "")\", \"src\": \"\(sourceOfTheWord ?? "")\"}")
        requestForPostingWord.httpBody = try? dataToSend.rawData()
        requestForPostingWord.httpMethod = "POST"
        
                Alamofire.request(requestForPostingWord).responseJSON { (responseData) in
                    if responseData.error == nil {
//                        let dataContainingUserDetails = JSON(responseData.data!)
        
                        print(String(data: responseData.data!, encoding: String.Encoding.utf8) as Any)
        
                    } else {
                        print(responseData.error as Any)
                    }
                }
        
//        let wordsDetails = WordDetails(context: PersistenceService.context)
//        wordsDetails.dateAdded = NSDate().timeIntervalSince1970 * 1000
//        wordsDetails.wordAddedBy = userName
//        wordsDetails.nameOfWord = addedWord
//        wordsDetails.meaningOfWord = wordMeaning
//        wordsDetails.sourceOfWord = sourceOfTheWord
//        PersistenceService.saveContext()
        
        let alert = UIAlertController(title: "Success!", message: "Word added to stream!!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in

            self.dismiss(animated: true, completion: {
                let name = NSNotification.Name.init(self.newWOrdAdded)
                NotificationCenter.default.post(name: name, object: nil)
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

/// extension used for text field related things
/// example keyboard will vanish if touched on the screen
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

extension newWordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headingForTableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch headingForTableViewCells[indexPath.section] {
        case "Word:":
            let wordCell =  addWordsTableView.dequeueReusableCell(withIdentifier: "wordsTableViewCells") as? WordTableViewCell
            wordCell?.headingLabel.text = "Word:"
            wordCell?.wordTextView.tag = 0
            return wordCell ?? cell
            
        case "Meaning:":
            let meaningCell =  addWordsTableView.dequeueReusableCell(withIdentifier: "wordsTableViewCells") as? WordTableViewCell
            meaningCell?.headingLabel.text = "Meaning:"
            meaningCell?.wordTextView.tag = 1
            meaningCell?.wordTextView.keyboardType = UIKeyboardType.default
            return meaningCell ?? cell

        case "Source:":
            let sourceCell =  addWordsTableView.dequeueReusableCell(withIdentifier: "wordsTableViewCells") as? WordTableViewCell
            sourceCell?.headingLabel.text = "Source:"
            sourceCell?.wordTextView.tag = 2
            sourceCell?.wordTextView.keyboardType = UIKeyboardType.default
            return sourceCell ?? cell

        default:
            break
        }
       
        
      return cell
    }
    
}
//use this to make the screen go up when the keyboard pops up
//type anything here inside this extension

extension newWordViewController: UIScrollViewDelegate {
}

// for the uitextview to display in the storyboard
extension newWordViewController {
    
    static func chechAndEnableAddButton() {
        
        guard newWordViewController.nameOfTheWord != "", newWordViewController.meaningOfTheWord != "", newWordViewController.sourceOfTheWord != "" else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SAVE_BUTTON_INVALIDATE), object: nil)
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SAVE_BUTTON_PRESSED), object: nil)
    }
}
class WordTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var wordTextView: UITextView!
    @IBOutlet weak var headingLabel: UILabel!
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type here" {
            textView.text = ""
        }
        textView.textColor = UIColor.black
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Type here"
            textView.textColor = #colorLiteral(red: 0.9214878678, green: 0.9216203094, blue: 0.9214587808, alpha: 1)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.tag == 0 {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 0{
            newWordViewController.nameOfTheWord = wordTextView.text
            
        } else if textView.tag == 1 {
            newWordViewController.meaningOfTheWord = wordTextView.text
        } else {
            newWordViewController.sourceOfTheWord = wordTextView.text
        }
        newWordViewController.chechAndEnableAddButton()
        
    }
    
}

