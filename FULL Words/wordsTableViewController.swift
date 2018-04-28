//
//  wordsTableViewController.swift
//  FULL Words
//
//  Created by User on 22/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit


class wordsTableViewController: UITableViewController {
    
    var addButtonBarButton: UIBarButtonItem!
    var userName: String?
    var wordsOfUserValues: [WordsOfUserValues]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension

        addButtonBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonPressed))
        tableView.reloadData()
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
       
        navigationController?.visibleViewController?.title = "Added Words"
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(addButtonBarButton, animated: false)

    }

    @objc func addButtonPressed(){
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "newwordviewcontroller") as? newWordViewController
        wordsViewController?.userName = userName
        self.present(wordsViewController!, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordsofthetableviewcells", for: indexPath) as! AddedWordsCells
        cell.addedWordLabel.text = wordsOfUserValues?[indexPath.item].addedWord.capitalizingFirstLetter()
        cell.addedWord = wordsOfUserValues?[indexPath.item].addedWord.capitalizingFirstLetter()
        cell.addedBy = userName!
        cell.sourceForTheWord = wordsOfUserValues?[indexPath.item].sourceOfTheWord
        cell.meaningLabel.text = wordsOfUserValues?[indexPath.item].wordMeaning
        cell.meaningOfTheWord = wordsOfUserValues?[indexPath.item].wordMeaning
        
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return wordsOfUserValues?.count ?? 0
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



/// class created for the custome cells in the table view
class AddedWordsCells: UITableViewCell {
    @IBOutlet weak var addedWordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
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


