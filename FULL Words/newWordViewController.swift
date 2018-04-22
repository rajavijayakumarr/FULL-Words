//
//  newWordViewController.swift
//  FULL Words
//
//  Created by User on 22/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class newWordViewController: UIViewController {
    var activeTextField: UITextField?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var newWordTextField: UITextField!
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var meaningTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.registerForKeyBoardNotification()
        
        self.scrollView.delegate = self
        nameTextField.delegate = self
        newWordTextField.delegate = self
        sourceTextField.delegate = self
        meaningTextField.delegate = self
        
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func submitButtonPressed(_ sender: UIButton) {
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
