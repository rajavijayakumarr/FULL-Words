//
//  learnViewController.swift
//  FULL Words
//
//  Created by User on 24/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class learnViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var wordTableView: UITableView!
    @IBOutlet weak var wordAndMeaningTableView: UITableView!
    
    var userName: String?
    var emailId: String?
    
    var numberOfWordsToLearn: WordsToLearnPerDay?
    
    var example1 = ["datasource", "delegate", "meaning", "strong", "volatile"]
    var example2 = ["animal", "bird", "insect", "plants", "humans"]
    var example3 = ["four legs", "two legs", "multiple legs", "one leg", "two legs"]
    
    var wordsOfUserValues: [WordsOfUserValues]?

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

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.visibleViewController?.navigationItem.title = "Learn"
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(nil, animated: false)
        numberOfWordsToLearn = WordsToLearnPerDay(rawValue: (userValues.integer(forKey: NUMBER_OF_WORDS_TO_LEARN) != 0 ? userValues.integer(forKey: NUMBER_OF_WORDS_TO_LEARN) : 2))
        print(numberOfWordsToLearn as Any)
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
        return numberOfWordsToLearn?.rawValue ?? 0
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
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if tableView == self.wordTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wordThatHasToBeLearned", for: indexPath) as? WordsToLearnCell
            cell?.wordThatHasMeaningLabel.text = wordsOfUserValues?[indexPath.item].addedWord.capitalizingFirstLetter()
            return cell!
        }
        
       else if tableView == self.wordAndMeaningTableView {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "wordsThatAreLearned", for: indexPath) as? LearnedWordsCell
            cell2?.meaningLabel.text = wordsOfUserValues?[indexPath.item].wordMeaning
            cell2?.wordThatHasMeaningLabel.text = wordsOfUserValues?[indexPath.item].addedWord.capitalizingFirstLetter()
            return cell2!

        }
        return cell
    }
    
}

class WordsToLearnCell: UITableViewCell {
    @IBOutlet weak var wordThatHasMeaningLabel: UILabel!
    
}

class LearnedWordsCell: UITableViewCell {
    @IBOutlet weak var wordThatHasMeaningLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    
}
