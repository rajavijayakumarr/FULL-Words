//
//  wordsTableViewController.swift
//  FULL Words
//
//  Created by User on 22/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit


class wordsTableViewController: UITableViewController {
    
//    var addButtonBarButton: UIBarButtonItem!
    var addButtonUIButton: UIButton!
    var userName: String?
    var wordsOfUserValues: [WordsOfUserValues]?
    let newWOrdAdded = "newWordAddedForWOrds"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension

 //       addButtonBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonPressed))
        let name = NSNotification.Name.init(rawValue: newWOrdAdded)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newWordAdded), name: name, object: nil)
        addButtonCustomization()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        addButtonUIButton.removeFromSuperview()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
         wordsOfUserValues = [WordsOfUserValues]()
        if let decodedValues = userValues.value(forKey: WordsOfUserValues.NEW_WORDS_VALUES + userName!) as? Dictionary<String, [Data]>{
            guard userName != nil else {return}
            let jsonData = decodedValues[userName!]
            guard jsonData != nil else {return}
            let jsonDecoder = JSONDecoder()
            for data in jsonData!{
                let valuesOfWords = try? jsonDecoder.decode(WordsOfUserValues.self, from: data)
                wordsOfUserValues?.append(valuesOfWords!)
            }
        }
        
        if let selection: IndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selection, animated: true)
        }
        navigationController?.visibleViewController?.title = "Words"
   //     navigationController?.visibleViewController?.navigationItem.setRightBarButton(addButtonBarButton, animated: false)
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(addButtonUIButton)

    }
    
    func addButtonCustomization() {
        addButtonUIButton = UIButton(type: .custom)
        addButtonUIButton.frame = CGRect(x: self.view.frame.maxX * 3/4, y: self.view.frame.maxY * 3/4, width: 50, height: 50)
        addButtonUIButton.tintColor = UIColor.red
        addButtonUIButton.layer.backgroundColor = UIColor.red.cgColor
        addButtonUIButton.layer.cornerRadius = addButtonUIButton.frame.width / 2
        addButtonUIButton.clipsToBounds = true
        addButtonUIButton.titleLabel?.adjustsFontSizeToFitWidth = true
        addButtonUIButton.titleLabel?.font = UIFont.init(name: "AvenirNext-UltraLightItalic", size: 50)
        addButtonUIButton.setTitle("+", for: UIControlState.normal)
        addButtonUIButton.addTarget(self, action: #selector(addButtonPressed), for: UIControlEvents.touchUpInside)
    }

    @objc func addButtonPressed(){
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "newwordviewcontroller") as? newWordViewController
        wordsViewController?.userName = userName
        self.present(wordsViewController!, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordsofthetableviewcells", for: indexPath) as! AddedWordsCells
        cell.addedWordLabel.text = wordsOfUserValues?[indexPath.section].addedWord.capitalizingFirstLetter()
        
        cell.addedWord = wordsOfUserValues?[indexPath.section].addedWord.capitalizingFirstLetter()
        cell.addedBy = userName!
        cell.viewOfAddedWordsCell.layer.cornerRadius = 5
        cell.viewOfAddedWordsCell.dropShadow(color: .black, opacity: 1, radius: 2)
        cell.sourceForTheWord = wordsOfUserValues?[indexPath.section].sourceOfTheWord
        cell.meaningLabel.text = "      " + (wordsOfUserValues?[indexPath.section].wordMeaning ?? "")
        
        cell.meaningOfTheWord = wordsOfUserValues?[indexPath.section].wordMeaning
        
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return wordsOfUserValues?.count ?? 0
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
  
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "viewWordsController") as? viewWordsViewController
        wordsViewController?.nameOfWord = wordsCell?.addedWord
        wordsViewController?.meaningOfWord = wordsCell?.meaningOfTheWord
        wordsViewController?.sourceOfWord = wordsCell?.sourceForTheWord
        wordsViewController?.wordAddedBy = wordsCell?.addedBy
        self.navigationController?.pushViewController(wordsViewController!, animated: true)
        
    }
}

extension wordsTableViewController {
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


