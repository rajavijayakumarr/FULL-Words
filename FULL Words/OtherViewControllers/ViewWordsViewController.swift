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
    var nameOfWord: String?
    var meaningOfWord: String?
    var sourceOfWord: String?
    var wordAddedBy: String?

    var headingFotTheTableViewCells = ["", "Source:", "Added By:"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        wordDetailsTableView.rowHeight = UITableViewAutomaticDimension
        wordDetailsTableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        headingFotTheTableViewCells.removeFirst()
        headingFotTheTableViewCells.insert(nameOfWord ?? "", at: headingFotTheTableViewCells.startIndex)
        wordDetailsTableView.delegate = self
        wordDetailsTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let selection: IndexPath = wordDetailsTableView.indexPathForSelectedRow{
            wordDetailsTableView.deselectRow(at: selection, animated: true)
        }
        wordDetailsTableView.reloadData()
        self.navigationController?.visibleViewController?.navigationItem.title = "Word Details"
    self.navigationController?.visibleViewController?.navigationItem.setHidesBackButton(false, animated: false)
    
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
        cell?.viewForWordDetails.dropShadow(color: .black, opacity: 1, radius: 2)
        cell?.viewForWordDetails.layer.cornerRadius = 5
        cell?.contentLabel.text = "      "
        switch headingFotTheTableViewCells[indexPath.section] {
        case nameOfWord:
            cell?.headingLabel.text = nameOfWord
            
            cell?.contentLabel.text?.append(meaningOfWord ?? "")
            
        case "Source:":
            cell?.headingLabel.text = "Source:"
            cell?.contentLabel.text?.append(sourceOfWord ?? "")
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressLabel(longPressGestureRecognizer:)))
            cell?.contentLabel.addGestureRecognizer(longPressGestureRecognizer)
            cell?.contentLabel.isUserInteractionEnabled = true
            cell?.contentLabel.becomeFirstResponder()

        case "Added By:":
            cell?.headingLabel.text = "Added By:"
            cell?.contentLabel.text?.append(wordAddedBy ?? "")

        default:
            break
        }
        
        return cell!
    }
    
    @objc private func longPressLabel (longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            print("long press began")
            
        } else if longPressGestureRecognizer.state == .ended {
            print("long press ended")
        }
        
    }
}


///custome tableviewcell for this table view
class WordDetailsTableViewCell: UITableViewCell {
    // identifire: tableViewForWordDetails
    @IBOutlet weak var viewForWordDetails: UIView!
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

