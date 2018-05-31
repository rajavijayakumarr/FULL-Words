//
//  viewWordsViewController.swift
//  FULL Words
//
//  Created by User on 25/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class ViewWordsViewController: UIViewController {
    
    var word: String?
    var meaning: String?
    var source: String?
    var wordAddedBy: String?
    var dateAdded: Double?
    var dateUpdated: Double?
    var userId: String?
    
    var shareBarButton: UIBarButtonItem!

    
    @IBOutlet weak var wordDetailsContainerView: UIView!
    @IBOutlet weak var wordContainerView: UIView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var addedOnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareToDisplayWordDetails()
        shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareBarButtonPressed))
        self.navigationItem.setRightBarButton(shareBarButton, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func prepareToDisplayWordDetails() {
        wordDetailsContainerView.layer.cornerRadius = 10
        wordDetailsContainerView.clipsToBounds = true
        wordLabel.text = word
        meaningLabel.text = meaning
        sourceLabel.text = source
        
        let dateVar = Date(timeIntervalSince1970: (dateUpdated ?? 1000)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        addedOnLabel.text = "Added on \(dateFormatter.string(from: dateVar))"
    }
    
    @objc private func longPressLabelWithURL (recognizer: UILongPressGestureRecognizer) {
        
        if let recognizerView = recognizer.view,
            let recognizerSuperView = recognizerView.superview
        {
            let menuController = UIMenuController.shared
            let openURLmenuItem = UIMenuItem.init(title: "Open", action: #selector(CopyableUILabel.openURLforMenuItem))
            menuController.menuItems = [openURLmenuItem]
            menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
            menuController.setMenuVisible(true, animated:true)
            recognizerView.becomeFirstResponder()
        }
    }
    @objc private func longPressLabel (recognizer: UILongPressGestureRecognizer) {

        if let recognizerView = recognizer.view,
                let recognizerSuperView = recognizerView.superview
            {
                let menuController = UIMenuController.shared
                menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
                menuController.setMenuVisible(true, animated:true)
                recognizerView.becomeFirstResponder()
            }
    }
    
    @objc func shareBarButtonPressed() {
        
        let fullWordsString = "#fullwords"
        let constructedStringToShare = "Hey, check out this new word that i've learnt, thought of sharing it with you.\n\nWord: \(word ?? "")\nMeaning: \(meaning ?? "")\nSource: \(source ?? "")\n\(fullWordsString)"
        let activityViewController = UIActivityViewController(activityItems: [constructedStringToShare], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
    }
}




///to make a uiview drop a shadow in side bottom and top
extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, radius: CGFloat = 1) {
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = radius
    }
}

//custome uilable for it to be copyable
class CopyableUILabel: UILabel {

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(openURLforMenuItem))
    }
    
    // MARK: - UIResponderStandardEditActions
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
    @objc func openURLforMenuItem() {
        let webviewInstance = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        if let urlRequest = URL(string: text!) {
            webviewInstance.loadRequest(URLRequest(url: urlRequest))
        }
    }
}

