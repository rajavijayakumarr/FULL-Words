//
//  toSelectNumberOfWordsToLearnViewController.swift
//  FULL Words
//
//  Created by User on 28/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

enum WordsToLearnPerDay: Int {
    case twoWords = 2, threeWords, fourWords, fiveWords
}

let NUMBER_OF_WORDS_TO_LEARN = "NUMBER_OF_WORDS_TO_LEARN"

class toSelectNumberOfWordsToLearnViewController: UIViewController {

    let daysForPickerView = ["2", "3", "4", "5"]
    var pickedDaysToLearn: WordsToLearnPerDay? = nil
    @IBOutlet weak var pickerViewForDays: UIPickerView!
    override func viewDidLoad() {
        // id: toSelectNoOfWordsController
        super.viewDidLoad()
        pickerViewForDays.delegate = self
        pickerViewForDays.dataSource = self
    
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.visibleViewController?.navigationItem.title = "Number of Words to learn"
        
        if let index = daysForPickerView.index(of: String(userValues.integer(forKey: NUMBER_OF_WORDS_TO_LEARN))) {
        pickerViewForDays.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension toSelectNumberOfWordsToLearnViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return daysForPickerView.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return daysForPickerView[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch daysForPickerView[row] {
        case "2":
            pickedDaysToLearn = .twoWords
        case "3":
            pickedDaysToLearn = .threeWords
        case "4":
            pickedDaysToLearn = .fourWords
        case "5":
            pickedDaysToLearn = .fiveWords
        default:
            break
        }
        userValues.set(pickedDaysToLearn?.rawValue, forKey: NUMBER_OF_WORDS_TO_LEARN)
    }
}
