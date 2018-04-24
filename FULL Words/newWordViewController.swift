//
//  newWordViewController.swift
//  FULL Words
//
//  Created by User on 22/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

struct WordsOfUserValues: Codable {
    var addedWord: String
    var wordMeaning: String
    var sourceOfTheWord: String
    
   static let NEW_WORDS_VALUES = "NEW_WORDS_VALUES"
   static let NEW_WORDS_VALUES_forNSKeyArchiever = "NEW_WORDS_VALUES_forNSKeyArchiever"
}

class newWordViewController: UIViewController {
    
    
    
    var activeTextField: UITextField?
    var userName: String?
    
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var newWordTextField: UITextField!
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var meaningTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.registerForKeyBoardNotification()
        
        self.scrollView.delegate = self
        newWordTextField.delegate = self
        sourceTextField.delegate = self
        meaningTextField.delegate = self
        
        
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
                self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard newWordTextField.text != "" && sourceTextField.text != "" && meaningTextField.text != "" else {
            let alert = UIAlertController(title: "Missing fields", message: "Please fill all the text fields!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let addedWord = newWordTextField.text!
        let wordMeaning = meaningTextField.text!
        let sourceOfTheWord = sourceTextField.text!
        // added to the nsuserdefaults from here delete and modify it when using the server
        
       if let decodedValues = userValues.value(forKey: WordsOfUserValues.NEW_WORDS_VALUES + userName!) as? Dictionary<String, [Data]>{
        guard userName != nil else {return}
        var jsonData = decodedValues[userName!]
        guard jsonData != nil else {return}
        let wordValuesOfTheUser = WordsOfUserValues(addedWord: addedWord, wordMeaning: wordMeaning, sourceOfTheWord: sourceOfTheWord)
        let jsonEncoder = JSONEncoder()
        let wordValuesToData = try? jsonEncoder.encode(wordValuesOfTheUser)
        jsonData?.append(wordValuesToData!)
        let userAndWordValues: [String: [Data]] = [userName!: jsonData!]
        userValues.set(userAndWordValues, forKey: WordsOfUserValues.NEW_WORDS_VALUES + userName!)
        print(userAndWordValues)
        
       } else {
            let wordValuesOfTheUser = WordsOfUserValues(addedWord: addedWord, wordMeaning: wordMeaning, sourceOfTheWord: sourceOfTheWord)
            let jsonEncoder = JSONEncoder()
            let wordValuesToData = try? jsonEncoder.encode(wordValuesOfTheUser)
            let userAndWordValues: [String: [Data]] = [userName!: [wordValuesToData!]]
            userValues.set(userAndWordValues, forKey: WordsOfUserValues.NEW_WORDS_VALUES + userName!)
        print(userAndWordValues)

        }
        
        let alert = UIAlertController(title: "Success!", message: "Word added to stream!!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
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
extension newWordViewController: UITextFieldDelegate, UIScrollViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
//        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
//            activeTextField = nextField
//            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//            nextField.becomeFirstResponder()
//        } else {
//            // Not found, so remove keyboard.
//            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//            textField.resignFirstResponder()
//        }
        // Do not add a line break
        textField.resignFirstResponder()
        view.endEditing(true)
        return false
    }
    
    func registerForKeyBoardNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func keyBoardWasShown(_ aNotification: Notification) {
        
        self.scrollView.isScrollEnabled = true
        let userValueDictionary = aNotification.userInfo
        let CGSizeOfKeyboard = userValueDictionary![UIKeyboardFrameEndUserInfoKey] as? NSValue
        var backGroundRect = activeTextField?.superview?.frame
        guard activeTextField != nil else {
            return
        }
//        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (CGSizeOfKeyboard?.cgRectValue.size.height)!, right: 0.0)
//
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
//        activeTextField?.frame.size
//
//        var frame = self.view.frame
//        frame.size.height -= (CGSizeOfKeyboard?.cgRectValue.size.height)!
//        if !frame.contains((activeTextField?.frame.origin)!){
//            self.scrollView.scrollRectToVisible((self.activeTextField?.frame)!, animated: true)
//
//        }

        backGroundRect?.size.height += (CGSizeOfKeyboard?.cgRectValue.size.height)!
        activeTextField?.superview?.frame(forAlignmentRect: backGroundRect!)
        scrollView.setContentOffset(CGPoint(x: 0.0, y: (activeTextField?.frame.origin.y)! - (CGSizeOfKeyboard?.cgRectValue.size.height)!), animated: true)
        
    }
    
    @objc func keyBoardWillBeHidden(_ aNotification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.origin.x, y: self.scrollView.frame.origin.y), animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}


