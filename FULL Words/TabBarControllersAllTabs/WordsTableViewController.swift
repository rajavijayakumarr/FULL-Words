//
//  wordsTableViewController.swift
//  FULL Words
//
//  Created by User on 22/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import CoreData


class WordsTableViewController: UITableViewController {
    typealias this = WordsTableViewController
    
    static var addButtonUIButton: UIButton!
    var userName: String?
    var wordsOfUserValues = [WordDetails]()
    let newWOrdAdded = "newWordAddedForWOrds"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension

        let name = NSNotification.Name.init(rawValue: newWOrdAdded)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newWordAdded), name: name, object: nil)
        addButtonCustomization()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        this.addButtonUIButton.removeFromSuperview()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let greenColor =  #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = greenColor
        self.navigationController?.navigationBar.barTintColor = greenColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.4472236633, green: 0.5693702102, blue: 0.6141017079, alpha: 1) as Any]
        self.navigationController?.view.tintColor = #colorLiteral(red: 0.4472236633, green: 0.5693702102, blue: 0.6141017079, alpha: 1)
        
        let fetchRequest: NSFetchRequest<WordDetails> = WordDetails.fetchRequest()
        do {
           wordsOfUserValues = try PersistenceService.context.fetch(fetchRequest)
        } catch {
            
        }
        
  
        if let selection: IndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selection, animated: true)
        }
        navigationController?.visibleViewController?.navigationItem.title = "Words"

        let window = UIApplication.shared.keyWindow
        window?.addSubview(this.addButtonUIButton)

    }
    
    func addButtonCustomization() {
        this.addButtonUIButton = UIButton(type: .custom)
        this.addButtonUIButton.frame = CGRect(x: self.view.frame.maxX * 5/6, y: self.view.frame.maxY * 5/6, width: 50, height: 50)
        this.addButtonUIButton.clipsToBounds = true
        this.addButtonUIButton.titleLabel?.adjustsFontSizeToFitWidth = true
        this.addButtonUIButton.tintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        this.addButtonUIButton.layer.backgroundColor = #colorLiteral(red: 0.4420010448, green: 0.5622541308, blue: 0.6140280962, alpha: 1)
        this.addButtonUIButton.layer.isOpaque = true
        this.addButtonUIButton.layer.cornerRadius = this.addButtonUIButton.frame.width / 2
        this.addButtonUIButton.dropShadow(color: .black, opacity: 1, radius: 3)
        this.addButtonUIButton.titleLabel?.font = UIFont.init(name: "AvenirNext-UltraLightItalic", size: 50)
        this.addButtonUIButton.setTitle("+", for: UIControlState.normal)
        this.addButtonUIButton.addTarget(self, action: #selector(addButtonPressed), for: UIControlEvents.touchUpInside)
    }

    @objc func addButtonPressed(){
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "newwordviewcontroller") as? NewWordViewController
        wordsViewController?.userName = userName
        self.present(wordsViewController!, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordsofthetableviewcells", for: indexPath) as! AddedWordsCells
        cell.addedWordLabel.text = wordsOfUserValues[indexPath.section].nameOfWord?.capitalizingFirstLetter()
        cell.addedWord = wordsOfUserValues[indexPath.section].nameOfWord?.capitalizingFirstLetter()
        cell.addedBy = userName!
        cell.viewOfAddedWordsCell.layer.cornerRadius = 5
        cell.viewOfAddedWordsCell.dropShadow(color: .black, opacity: 0.3, radius: 0.5)
        
        cell.sourceForTheWord = wordsOfUserValues[indexPath.section].sourceOfWord
        cell.meaningLabel.text = wordsOfUserValues[indexPath.section].meaningOfWord
        cell.meaningOfTheWord = wordsOfUserValues[indexPath.section].meaningOfWord
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return wordsOfUserValues.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        let wordsCell = tableView.cellForRow(at: indexPath) as? AddedWordsCells
  
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "viewWordsController") as? ViewWordsViewController
        wordsViewController?.nameOfWord = wordsCell?.addedWord
        wordsViewController?.meaningOfWord = wordsCell?.meaningOfTheWord
        wordsViewController?.sourceOfWord = wordsCell?.sourceForTheWord
        wordsViewController?.wordAddedBy = wordsCell?.addedBy
        
        self.navigationController?.pushViewController(wordsViewController!, animated: true)
        
    }
}

extension WordsTableViewController {
    @objc func newWordAdded() {
        tableView.reloadData()
    }
}



/// class created for the custome cells in the table view
class AddedWordsCells: UITableViewCell {
    @IBOutlet weak var addedWordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var viewOfAddedWordsCell: UIView!
    var addedWord: String?
    var meaningOfTheWord: String?
    var addedBy: String?
    var sourceForTheWord: String?
}

/// to capitalize the first string
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}


