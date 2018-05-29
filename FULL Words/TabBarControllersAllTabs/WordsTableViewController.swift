//
//  wordsTableViewController.swift
//  FULL Words
//
//  Created by User on 22/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import MBProgressHUD

let STARTING_TIME_VALUE = "STARTING_TIME_VALUE"
let ENDING_TIME_VALUE = "ENDING_TIME_VALUE"

class WordsTableViewController: UITableViewController {
    typealias this = WordsTableViewController
    var refreshController: UIRefreshControl? = {
        let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(pullToRefreshHandler), for: UIControlEvents.valueChanged)
        refreshController.tintColor = #colorLiteral(red: 0.2419127524, green: 0.6450607777, blue: 0.9349957108, alpha: 1)
        return refreshController
    }()
    
    static var addButtonUIButton: UIButton!
    open var userName: String?
    var isUserAlreadyLoggedIn: Bool?
    static var words = [WordDetails]()
    var wordsByWeek: [Int: [WordDetails]] = [:]
    
    var sectionHeaders: (stringRep: [(from: String, to: String)], millis: [(from: TimeInterval, to: TimeInterval)]) = ([], [])
    
    //this is the name of the notification that will reload the table data if any new word is added in the newWordViewController
    let wordAdded = "newWordAddedForWOrds"
    override func viewDidLoad() {
        super.viewDidLoad()
        handleFetchingWords()
        handleGettingWeekValues()
        arrangeWordsByWeek()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
        if let refreshController = refreshController {
            tableView.addSubview(refreshController)
        }
        let name = NSNotification.Name.init(rawValue: wordAdded)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newWordAdded), name: name, object: nil)
        addButtonCustomization()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        this.addButtonUIButton.removeFromSuperview()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
        self.navigationController?.navigationBar.barStyle = .default
        let color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = color
        self.navigationController?.navigationBar.barTintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) as Any]
        self.navigationController?.view.tintColor = #colorLiteral(red: 0.2419127524, green: 0.6450607777, blue: 0.9349957108, alpha: 1)
        navigationController?.visibleViewController?.navigationItem.title = "Words"

        let window = UIApplication.shared.keyWindow
        window?.addSubview(this.addButtonUIButton)

    }
    
    fileprivate func arrangeWordsByWeek() {
        wordsByWeek = [:]
        for (index, fromToMilliseconds) in sectionHeaders.millis.enumerated() {
            wordsByWeek[index] = WordsTableViewController.words.filter { (word) -> Bool in
                switch word.dateUpdated {
                case fromToMilliseconds.from ... fromToMilliseconds.to : return true
                default : return false
                }
            }
        }
    }
    
    fileprivate func handleGettingWeekValues() {
        let fromDate = WordsTableViewController.words.last?.dateUpdated
        let toDate = WordsTableViewController.words.first?.dateUpdated
        print(fromDate as Any)
        print(toDate as Any)
        var value: (stringRep: [(from: String, to: String)], millis: [(from: TimeInterval, to: TimeInterval)]) = ([], [])
        if let fromDate = fromDate, let toDate = toDate {
            value = Date.totalNumberOfWeeksRoundOffByWeekends(From: fromDate, To: toDate)
        }
        sectionHeaders = value
    }
    
    fileprivate func handleFetchingWords() {
        if let userLoggedIn = isUserAlreadyLoggedIn {
            if  userLoggedIn {
                //spinner view
                let spinnerView = MBProgressHUD.showAdded(to: self.view, animated: true)
                spinnerView.label.text = "Loading..."
                getWords() { [weak self] (success, error, _) in
                    guard let strongSelf = self else {return}
                    if success {
                        DispatchQueue.main.async {
                            strongSelf.fetchWordsFromCoreData()
                            UIView.transition(with: strongSelf.tableView,
                                              duration: 0.35,
                                              options: .transitionCrossDissolve,
                                              animations: { strongSelf.tableView.reloadData() })
                        }
                    } else {
                        MBProgressHUD.hide(for: strongSelf.view, animated: true)
                    }
                }
            } else {
                fetchWordsFromCoreData()
            }
        }
    }
    
    func addButtonCustomization() {
        this.addButtonUIButton = UIButton(type: .custom)
        this.addButtonUIButton.frame = CGRect(x: self.view.frame.maxX * 4.9/6, y: self.view.frame.maxY * 4.9/6, width: 50, height: 50)
        this.addButtonUIButton.clipsToBounds = true
        this.addButtonUIButton.titleLabel?.adjustsFontSizeToFitWidth = true
        this.addButtonUIButton.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        this.addButtonUIButton.layer.backgroundColor = #colorLiteral(red: 0.9044587016, green: 0.2473695874, blue: 0.223312825, alpha: 1)
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

        cell.wordLabel.text = wordsByWeek[indexPath.section]?[indexPath.item].nameOfWord?.capitalizingFirstLetter()
        cell.word = wordsByWeek[indexPath.section]?[indexPath.item].nameOfWord?.capitalizingFirstLetter()
        cell.wordAddedBy = userName!
        cell.cardView.layer.cornerRadius = 5
        cell.cardView.dropShadow(color: .black, opacity: 0.3, radius: 0.5)
    
        cell.source = wordsByWeek[indexPath.section]?[indexPath.item].sourceOfWord
        cell.meaningLabel.text = wordsByWeek[indexPath.section]?[indexPath.item].meaningOfWord
        cell.meaning = wordsByWeek[indexPath.section]?[indexPath.item].meaningOfWord
        
        cell.dateAdded = wordsByWeek[indexPath.section]?[indexPath.item].dateAdded
        cell.dateUpdated = wordsByWeek[indexPath.section]?[indexPath.item].dateUpdated
        cell.userId = wordsByWeek[indexPath.section]?[indexPath.item].userId
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this is the element after which we have to load the non loaded data to the bottom of the table view
        let thresholdElement = WordsTableViewController.words.count - 5
        if indexPath.row == thresholdElement {
            //spinner
            print("called when the user drags to the botton")
            print(thresholdElement)
            
            // here the words will be loaded whenever the user is going to hit the bottom of the tableview
            getWords(toTime: userDefaultsObject.double(forKey: ENDING_TIME_VALUE) - 1) { [weak self] (success, error, jsonData) in
                guard let strongSelf = self else {return}

                if success {
                    guard jsonData?.count != 0 else {
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.fetchWordsFromCoreData()
                        UIView.transition(with: strongSelf.tableView,
                                          duration: 0.35,
                                          options: .transitionCrossDissolve,
                                          animations: { strongSelf.tableView.reloadData() })
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print(sectionHeaders.stringRep.count)
        return sectionHeaders.stringRep.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return wordsByWeek[section]?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders.stringRep[section].from + " - " + sectionHeaders.stringRep[section].to
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wordsCell = tableView.cellForRow(at: indexPath) as? AddedWordsCells
  
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "viewWordsController") as? ViewWordsViewController
        wordsViewController?.word = wordsCell?.word
        wordsViewController?.meaning = wordsCell?.meaning
        wordsViewController?.source = wordsCell?.source
        wordsViewController?.wordAddedBy = wordsCell?.wordAddedBy
        wordsViewController?.dateAdded = wordsCell?.dateAdded
        wordsViewController?.dateUpdated = wordsCell?.dateUpdated
        wordsViewController?.userId = wordsCell?.userId
        self.navigationController?.pushViewController(wordsViewController!, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //function that handles the swipe to share feature
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            let fullWordsString = "#fullwords"
            let cell = tableView.cellForRow(at: indexPath) as? AddedWordsCells
            let word = cell?.word ?? ""
            let meaning = cell?.meaning ?? ""
            let source = cell?.source ?? ""
            let constructedStringToShare = "Hey, check out this new word that i've learnt, thought of sharing it with you.\n\nWord: \(word)\nMeaning: \(meaning)\nSource: \(source)\n\(fullWordsString)"
            let activityViewController = UIActivityViewController(activityItems: [constructedStringToShare], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
            completionHandler(true)
        }
 
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [share])
        swipeActionConfig.performsFirstActionWithFullSwipe = true
        return swipeActionConfig
    }
    
    func fetchWordsFromCoreData() {
        let fetchRequest: NSFetchRequest<WordDetails> = WordDetails.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateUpdated", ascending: false, selector: nil)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            WordsTableViewController.words = try PersistenceService.context.fetch(fetchRequest)
        } catch {
        }
    }
    
    @objc func pullToRefreshHandler() {
        guard let latestWordAdded = WordsTableViewController.words.first else {
            return
        }
        let latestWordAddedTime = latestWordAdded.dateAdded + 1
        getWords(fromTime: latestWordAddedTime) { [weak self] (success, error, jsonArray) in
            guard let strongSelf = self else {return}
            var jArray = jsonArray
            if success {
                strongSelf.refreshController?.endRefreshing()
                DispatchQueue.main.async {
                    strongSelf.fetchWordsFromCoreData()
                    strongSelf.tableView.reloadData()
                    strongSelf.refreshController?.endRefreshing()
                }
                if var countOfWords = jArray?.count {
                    while countOfWords == 10 {
                        var endTime: Double = 0.0
                        for wordValues in jArray! {
                            endTime = wordValues["updatedAt"].doubleValue
                        }
                        strongSelf.getWords(fromTime: latestWordAddedTime, toTime: endTime) { (s, e, j) in
                            if s {
                                DispatchQueue.main.async {
                                    strongSelf.fetchWordsFromCoreData()
                                    strongSelf.tableView.reloadData()
                                    strongSelf.refreshController?.endRefreshing()
                                    jArray = j
                                    countOfWords = j?.count ?? 0
                                }
                            } else {
                                strongSelf.refreshController?.endRefreshing()
                                let alert = UIAlertController(title: "Couldn't refresh words!", message: "try again!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                                    strongSelf.refreshController?.endRefreshing()
                                }))
                                strongSelf.present(alert, animated: true)
                            }
                        }
                    }
                }
            } else {
                strongSelf.refreshController?.endRefreshing()
                let alert = UIAlertController(title: "Couldn't refresh words!", message: "try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                strongSelf.present(alert, animated: true)
            }
        }
    }
    
    func getWords(fromTime firstWordDate: Double = 1, toTime lastWordDate: Double = Double(Date().timeIntervalSince1970) * 1000 , _ completionBlock: @escaping (_ success: Bool, _ error: NSError?, _ message: [JSON]?) -> ()) {
//        spinnerview
        let accessToken = userDefaultsObject.value(forKey: ACCESS_TOKEN) as! String
        let tokenType = userDefaultsObject.value(forKey: TOKEN_TYPE) as! String
        
            var urlRequest = URLRequest(url: URL(string: FULL_WORDS_ME_API + "&endTime=\(Int(lastWordDate))" + "&startTime=\(Int(firstWordDate))")!)
            print("*************************************************")
            print(FULL_WORDS_ME_API + "&endTime=\(Int(lastWordDate))" + "&startTime=\(firstWordDate)")
            print("*************************************************")
        urlRequest.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        Alamofire.request(urlRequest).responseJSON { (responseData) in
            if responseData.error == nil  {
                print("*******************************************************")
                print(String(data: responseData.data!, encoding: String.Encoding.utf8) as Any)
                let responseJSON_Data = JSON(responseData.data!)
               
                if responseJSON_Data["response"].boolValue {
                    let arrayOfJSON = responseJSON_Data["data"]["words"].arrayValue
                    for JSONwordData in arrayOfJSON {
                        let wordDetails = WordDetails(context: PersistenceService.context)
                        wordDetails.dateAdded = JSONwordData["createdAt"].doubleValue
                        wordDetails.dateUpdated = JSONwordData["updatedAt"].doubleValue
                        wordDetails.nameOfWord = JSONwordData["word"].stringValue
                        wordDetails.sourceOfWord = JSONwordData["src"].stringValue
                        wordDetails.meaningOfWord = JSONwordData["desc"].stringValue
                        wordDetails.wordAddedBy = self.userName
                        wordDetails.userId = JSONwordData["userId"].stringValue
                        PersistenceService.saveContext()
                        userDefaultsObject.set(JSONwordData["createdAt"].doubleValue, forKey: ENDING_TIME_VALUE)
                    }
                    completionBlock(true, nil, responseJSON_Data["data"]["words"].arrayValue)
                    self.refreshController?.endRefreshing()
                    MBProgressHUD.hide(for: self.view, animated: true)
                    //spinner
                } else {
                    let message = responseJSON_Data["msg"].stringValue
                    let error = responseJSON_Data["error"].stringValue
                    completionBlock(false, NSError(domain: error, code: 2, userInfo: nil), nil)
                    let alert = UIAlertController(title: message, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        self.refreshController?.endRefreshing()
                    }))
                    self.present(alert, animated: true, completion: nil)
                    //spinner
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            } else {
                
                var title = "", message = ""
                //spinner
                MBProgressHUD.hide(for: self.view, animated: true)
                self.refreshController?.endRefreshing()
                switch responseData.result {
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        title = "Server timed out!"
                        message = "try again"
                    } else {
                        title = "Netword error!"
                        message = "Check your internet connection and try again"
                    }
                default: break
                }
                print(title)
                print(message)
                //spinner
                MBProgressHUD.hide(for: self.view, animated: true)
                self.refreshController?.endRefreshing()
                completionBlock(false, NSError(domain: title + ": " + message, code: 3, userInfo: nil), nil)
            }
        }
    }
}

//this is the function that handles 3d touch events
//extension WordsTableViewController: UIViewControllerPreviewingDelegate {
//
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//
//
//    }
//
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//
//    }
//}

extension WordsTableViewController {
    @objc func newWordAdded() {
        fetchWordsFromCoreData()
        arrangeWordsByWeek()
        UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        }
}

/// class created for the custome cells in the table view
class AddedWordsCells: UITableViewCell {
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    var word: String?
    var meaning: String?
    var wordAddedBy: String?
    var source: String?
    var dateAdded: Double?
    var dateUpdated: Double?
    var userId: String?
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

