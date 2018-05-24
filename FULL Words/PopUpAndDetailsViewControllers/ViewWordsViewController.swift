//
//  viewWordsViewController.swift
//  FULL Words
//
//  Created by User on 25/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class ViewWordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   
    
    @IBOutlet weak var wordDetailsTableView: UITableView!
    var word: String?
    var meaning: String?
    var source: String?
    var wordAddedBy: String?

    var headingFotTheTableViewCells = ["", "Source:", "Added By:"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        wordDetailsTableView.rowHeight = UITableViewAutomaticDimension
        wordDetailsTableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        headingFotTheTableViewCells.removeFirst()
        headingFotTheTableViewCells.insert(word ?? "", at: headingFotTheTableViewCells.startIndex)
        wordDetailsTableView.delegate = self
        wordDetailsTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let selection: IndexPath = wordDetailsTableView.indexPathForSelectedRow{
            wordDetailsTableView.deselectRow(at: selection, animated: true)
        }
        wordDetailsTableView.reloadData()
        self.navigationController?.visibleViewController?.navigationItem.title = "Word Details"
        self.navigationController?.visibleViewController?.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.title = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.visibleViewController?.navigationItem.setHidesBackButton(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return headingFotTheTableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewForWordDetails", for: indexPath) as? WordDetailsTableViewCell
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressLabel(recognizer:)))
//        let longPressGestureWithURL = UILongPressGestureRecognizer(target: self, action: #selector(longPressLabelWithURL(recognizer:)))
        switch headingFotTheTableViewCells[indexPath.section] {
        case word:
            cell?.headingLabel.text = word
            cell?.contentLabel.text = meaning
            cell?.contentLabel.isUserInteractionEnabled = true
            cell?.contentLabel.addGestureRecognizer(longPressGestureRecognizer)
            cell?.contentLabel.becomeFirstResponder()
            
        case "Source:":
            cell?.headingLabel.text = "Source:"
            cell?.contentLabel.text = source
            cell?.contentLabel.addGestureRecognizer(longPressGestureRecognizer)
            cell?.contentLabel.isUserInteractionEnabled = true
            cell?.contentLabel.becomeFirstResponder()

        case "Added By:":
            cell?.headingLabel.text = "Added By:"
            cell?.contentLabel.text = wordAddedBy

        default:
            break
        }
        
        return cell!
    }
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
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
}


///custome tableviewcell for this table view
class WordDetailsTableViewCell: UITableViewCell {
    // identifire: tableViewForWordDetails
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
}

///to make a uiview drop a shadow in side bottom and top
extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, radius: CGFloat = 1) {
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
//        layer.shadowOffset = CGSize.zero
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

