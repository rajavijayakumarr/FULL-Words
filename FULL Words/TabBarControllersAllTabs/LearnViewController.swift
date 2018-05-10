//
//  learnViewController.swift
//  FULL Words
//
//  Created by User on 24/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import CoreData

class LearnViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var wordTableView: UITableView!
    @IBOutlet weak var wordAndMeaningTableView: UITableView!
    
    var userName: String?
    var emailId: String?
    
    var numberOfWordsToLearn: WordsToLearnPerDay?
    
    var wordsOfUserValues = [WordDetails]()

    override func viewDidLoad() {
        super.viewDidLoad()
        wordTableView.delegate = self
        wordTableView.dataSource = self
        wordAndMeaningTableView.delegate = self
        wordAndMeaningTableView.dataSource = self
        
        self.wordTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.wordTableView.rowHeight = UITableViewAutomaticDimension
        
        self.wordAndMeaningTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.wordAndMeaningTableView.rowHeight = UITableViewAutomaticDimension
        

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let greenColor =  #colorLiteral(red: 0.3745603087, green: 0.7311893369, blue: 0.3431609594, alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = greenColor
        self.navigationController?.navigationBar.barTintColor = greenColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1) as Any]
        self.navigationController?.view.tintColor = #colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)
        
        self.navigationController?.visibleViewController?.navigationItem.title = "Learn"
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)
        numberOfWordsToLearn = WordsToLearnPerDay(rawValue: (userValues.integer(forKey: NUMBER_OF_WORDS_TO_LEARN) != 0 ? userValues.integer(forKey: NUMBER_OF_WORDS_TO_LEARN) : 2))
//        print(numberOfWordsToLearn as Any)
        
        let fetchRequest: NSFetchRequest<WordDetails> = WordDetails.fetchRequest()
        do {
            wordsOfUserValues = try PersistenceService.context.fetch(fetchRequest)
        }catch {
            
        }
        
        wordTableView.reloadData()
        wordAndMeaningTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }
    
    
    func textViewDidChange(textView: UITextView) {
        var bounds : CGRect = textView.bounds
        bounds.size.height = textView.contentSize.height
        textView.bounds = bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return numberOfWordsToLearn?.rawValue ?? 0
        return ((numberOfWordsToLearn?.rawValue)! <= wordsOfUserValues.count ? (numberOfWordsToLearn?.rawValue)!: wordsOfUserValues.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        if tableView == self.wordTableView {
          //  let wordsCell = tableView.cellForRow(at: indexPath) as? WordsToLearnCell
            
            
        } else if tableView == self.wordAndMeaningTableView {
            let learnedWordCell = tableView.cellForRow(at: indexPath) as? LearnedWordsCell
            
            let viewWordsController = self.storyboard?.instantiateViewController(withIdentifier: "viewWordsController") as? ViewWordsViewController
            viewWordsController?.nameOfWord = learnedWordCell?.wordThatHasMeaning
            viewWordsController?.meaningOfWord = learnedWordCell?.meaningOfWord
            viewWordsController?.sourceOfWord = learnedWordCell?.sourceOfWord
            viewWordsController?.wordAddedBy = userName
            self.navigationController?.pushViewController(viewWordsController!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if tableView == self.wordTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wordThatHasToBeLearned", for: indexPath) as? WordsToLearnCell
            cell?.wordThatHasMeaningLabel.text = wordsOfUserValues[indexPath.item].nameOfWord?.capitalizingFirstLetter()
            cell?.wordThatHasMeaningView.layer.cornerRadius = 5
            cell?.wordThatHasMeaningView.dropShadow(color: .black)
            return cell!
        }
        
       else if tableView == self.wordAndMeaningTableView {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "wordsThatAreLearned", for: indexPath) as? LearnedWordsCell
            cell2?.meaningLabel.text = "      " + wordsOfUserValues[indexPath.item].meaningOfWord!
            cell2?.wordThatHasMeaningLabel.text =  wordsOfUserValues[indexPath.item].nameOfWord?.capitalizingFirstLetter()
            cell2?.learnedWordsView.layer.cornerRadius = 5
            cell2?.learnedWordsView.dropShadow(color: .black)
            
            cell2?.meaningOfWord = wordsOfUserValues[indexPath.item].meaningOfWord
            cell2?.wordThatHasMeaning = wordsOfUserValues[indexPath.item].nameOfWord
            cell2?.sourceOfWord = wordsOfUserValues[indexPath.item].sourceOfWord
            return cell2!

        }
        return cell
    }
    
}

class WordsToLearnCell: UITableViewCell {
    @IBOutlet weak var wordThatHasMeaningLabel: UILabel!
    @IBOutlet weak var wordThatHasMeaningView: UIView!
    
}

class LearnedWordsCell: UITableViewCell {
    @IBOutlet weak var wordThatHasMeaningLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var learnedWordsView: UIView!
    
    var meaningOfWord: String?
    var wordThatHasMeaning: String?
    var sourceOfWord: String?
    
}
