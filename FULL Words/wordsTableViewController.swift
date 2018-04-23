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
        
        addButtonBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.visibleViewController?.title = "Added Words"
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(addButtonBarButton, animated: false)
        tableView.reloadData()

    }

    @objc func addButtonPressed(){
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "newwordviewcontroller") as? newWordViewController
        wordsViewController?.userName = userName
        self.present(wordsViewController!, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordsofthetableviewcells", for: indexPath) as! AddedWordsCells
        //do the additional setup here as to display the table view cells
        cell.addedWordLabel.text = wordsOfUserValues?[indexPath.item].addedWord
        cell.addedByLabel.text = "addedBy: " + userName!
        cell.meaningLabel.text = wordsOfUserValues?[indexPath.item].wordMeaning
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
}


/// class created for the custome cells in the table view
class AddedWordsCells: UITableViewCell {
    @IBOutlet weak var addedWordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var addedByLabel: UILabel!
    
}


