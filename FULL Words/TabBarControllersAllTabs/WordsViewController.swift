//
//  WordsViewController.swift
//  FULL Words
//
//  Created by User on 01/06/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import MBProgressHUD
import Firebase

let STARTING_TIME_VALUE = "STARTING_TIME_VALUE"
let ENDING_TIME_VALUE = "ENDING_TIME_VALUE"

class WordsViewController: UIViewController {
    typealias this = WordsViewController
    var refreshController: UIRefreshControl? = {
        let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(pullToRefreshHandler), for: UIControlEvents.valueChanged)
        refreshController.tintColor = #colorLiteral(red: 0.4915913939, green: 0.5727371573, blue: 0.6729450226, alpha: 1)
        return refreshController
    }()
    
    open var userName: String?
    var isUserAlreadyLoggedIn: Bool?
    static var words = [WordDetails]()
    var wordsByWeek: [Int: [WordDetails]] = [:]
    
    var sectionHeaders: (stringRep: [(from: String, to: String)], millis: [(from: TimeInterval, to: TimeInterval)]) = ([], [])
    let wordAdded = "newWordAddedForWOrds"



    @IBOutlet weak var wordsTableView: UITableView!
    static var addButtonUIButton: UIButton!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        handleFetchingWords()
        handleGettingWeekValues()
        arrangeWordsByWeek()
        
        wordsTableView.delegate = self
        wordsTableView.dataSource = self
        
        wordsTableView.rowHeight = 135
        wordsTableView.estimatedRowHeight = 105
        
        if let refreshController = refreshController {
            wordsTableView.addSubview(refreshController)
        }
        let name = NSNotification.Name.init(rawValue: wordAdded)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newWordAdded), name: name, object: nil)
        addButtonCustomization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        let window = UIApplication.shared.keyWindow
        window?.addSubview(this.addButtonUIButton)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        this.addButtonUIButton.removeFromSuperview()
    }
}

extension WordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(wordsByWeek[section]?.count as Any)
        return wordsByWeek[section]?.count ?? 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print(sectionHeaders.stringRep.count)
        return sectionHeaders.stringRep.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {return "This Week"}
        if section == 1 {return "Last Week"}
        return sectionHeaders.stringRep[section].from + " - " + sectionHeaders.stringRep[section].to
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Brown-Regular", size: 17)
        header.textLabel?.textColor = #colorLiteral(red: 0.4915913939, green: 0.5727371573, blue: 0.6729450226, alpha: 1)
        header.backgroundView?.backgroundColor = #colorLiteral(red: 0.9495925307, green: 0.9580991864, blue: 0.9792678952, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            let cells = tableView.cellForRow(at: indexPath) as? WordsTableViewCell
            if let width = cells?.frame.width, let height = cells?.frame.height {
                sourceView.bounds.size = CGSize(width: width, height: height)
            }
            sourceView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.09934182363)
            sourceView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.09934182363)
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wordsCell = tableView.cellForRow(at: indexPath) as? WordsTableViewCell
        
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this is the element after which we have to load the non loaded data to the bottom of the table view
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if (indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex) {
            //spinner
            print("called when the user drags to the botton")
            
            // here the words will be loaded whenever the user is going to hit the bottom of the tableview
            getWords(toTime: userDefaultsObject.double(forKey: ENDING_TIME_VALUE) - 1) { [weak self] (success, error, jsonData) in
                guard let strongSelf = self else {return}
                if success {
                    guard jsonData?.count != 0 else {
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.fetchWordsFromCoreData()
                        strongSelf.handleGettingWeekValues()
                        strongSelf.arrangeWordsByWeek()
                        UIView.transition(with: strongSelf.wordsTableView,
                                          duration: 0.35,
                                          options: .transitionCrossDissolve,
                                          animations: { strongSelf.wordsTableView.reloadData() })
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordListTableViewCell", for: indexPath) as! WordsTableViewCell
        
        cell.wordLabel.text = wordsByWeek[indexPath.section]?[indexPath.item].nameOfWord?.capitalizingFirstLetter()
        cell.word = wordsByWeek[indexPath.section]?[indexPath.item].nameOfWord?.capitalizingFirstLetter()
        cell.wordAddedBy = userName!

        cell.wordMeaningContainerView.layer.cornerRadius = 5
        cell.wordMeaningContainerView.clipsToBounds = true
        
        cell.source = wordsByWeek[indexPath.section]?[indexPath.item].sourceOfWord
        cell.meaningLabel.text = wordsByWeek[indexPath.section]?[indexPath.item].meaningOfWord
        cell.meaning = wordsByWeek[indexPath.section]?[indexPath.item].meaningOfWord
        
        cell.dateAdded = wordsByWeek[indexPath.section]?[indexPath.item].dateAdded
        cell.dateUpdated = wordsByWeek[indexPath.section]?[indexPath.item].dateUpdated
        cell.userId = wordsByWeek[indexPath.section]?[indexPath.item].userId
        
        return cell
    }

    
}

// for all the method customization's
extension WordsViewController {
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
                    MBProgressHUD.hide(for: self.navigationController?.view ?? self.view, animated: true)
                    //spinner
                }
                else if responseJSON_Data["error"].stringValue == "unauthorized_request"{
                    self.refreshTheAccessToken() {[weak self] (success) in
                        guard let strongSelf = self else {
                            return
                        }
                        if success {
                            var urlRequest_new = URLRequest(url: URL(string: FULL_WORDS_ME_API + "&endTime=\(Int(lastWordDate))" + "&startTime=\(Int(firstWordDate))")!)
                            urlRequest_new.setValue(tokenType + " " + (userDefaultsObject.value(forKey: ACCESS_TOKEN) as! String), forHTTPHeaderField: "Authorization")
                            urlRequest_new.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            urlRequest_new.httpMethod = "GET"
                            
                            
                            Alamofire.request(urlRequest_new).responseJSON { (responseData) in
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
                                            wordDetails.wordAddedBy = strongSelf.userName
                                            wordDetails.userId = JSONwordData["userId"].stringValue
                                            PersistenceService.saveContext()
                                            userDefaultsObject.set(JSONwordData["createdAt"].doubleValue, forKey: ENDING_TIME_VALUE)
                                        }
                                        completionBlock(true, nil, responseJSON_Data["data"]["words"].arrayValue)
                                        strongSelf.refreshController?.endRefreshing()
                                        MBProgressHUD.hide(for: strongSelf.navigationController?.view ?? strongSelf.view, animated: true)
                                        //spinner
                                    }
                                    else {
                                        let message = responseJSON_Data["msg"].stringValue
                                        let error = responseJSON_Data["error"].stringValue
                                        completionBlock(false, NSError(domain: error, code: 2, userInfo: nil), nil)
                                        let alert = UIAlertController(title: message, message: error, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                                            strongSelf.refreshController?.endRefreshing()
                                        }))
                                        strongSelf.present(alert, animated: true, completion: nil)
                                        //spinner
                                        MBProgressHUD.hide(for: strongSelf.navigationController?.view ?? strongSelf.view, animated: true)
                                    }
                                } else {
                                    
                                    var title = "", message = ""
                                    //spinner
                                    MBProgressHUD.hide(for: strongSelf.navigationController?.view ?? strongSelf.view, animated: true)
                                    strongSelf.refreshController?.endRefreshing()
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
                                    MBProgressHUD.hide(for: strongSelf.navigationController?.view ?? strongSelf.view, animated: true)
                                    strongSelf.refreshController?.endRefreshing()
                                    completionBlock(false, NSError(domain: title + ": " + message, code: 3, userInfo: nil), nil)
                                }
                            }
                        } else {
                            let alert = UIAlertController(title: "error", message: "cannot refresh the access token", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            strongSelf.present(alert, animated: true)
                            completionBlock(false, NSError(domain: "error_refreshing_token", code: 3, userInfo: nil), nil)
                        }
                    }
                }
                else {
                    let message = responseJSON_Data["msg"].stringValue
                    let error = responseJSON_Data["error"].stringValue
                    completionBlock(false, NSError(domain: error, code: 2, userInfo: nil), nil)
                    let alert = UIAlertController(title: message, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        self.refreshController?.endRefreshing()
                    }))
                    self.present(alert, animated: true, completion: nil)
                    //spinner
                    MBProgressHUD.hide(for: self.navigationController?.view ?? self.view, animated: true)
                }
            } else {
                
                var title = "", message = ""
                //spinner
                MBProgressHUD.hide(for: self.navigationController?.view ?? self.view, animated: true)
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
                MBProgressHUD.hide(for: self.navigationController?.view ?? self.view, animated: true)
                self.refreshController?.endRefreshing()
                completionBlock(false, NSError(domain: title + ": " + message, code: 3, userInfo: nil), nil)
            }
        }
    }

    func refreshTheAccessToken(completionBlock: @escaping (_ success: Bool) -> ()) {
        print("this is sent if the access token is expired and refresh token is sent to refresh the access token")
        var urlRequestForToken = URLRequest(url: URL(string: TOKEN_URL)!)
        var data:Data = "refresh_token=\(userDefaultsObject.value(forKey: REFRESH_TOKEN) as? String ?? "token_revoked")".data(using: .utf8)!
        data.append("&client_id=\(CLIENT_ID)".data(using: .utf8)!)
        data.append("&client_secret=\(CLIENT_SECRET)".data(using: .utf8)!)
        data.append("&grant_type=refresh_token".data(using: .utf8)!)
        urlRequestForToken.httpBody = data
        urlRequestForToken.httpMethod = "POST"
        
        Alamofire.request(urlRequestForToken).responseJSON { (responseData) in
            if responseData.error == nil{
                print(responseData)
                var dataContainingTokens = JSON(responseData.data!)
                let accessToken = dataContainingTokens["access_token"].stringValue
                let tokenType = dataContainingTokens["token_type"].stringValue
                
                print("****************************************************************************************")
                print("accessToken: \(accessToken)\ntoken_type: \(tokenType)")
                userDefaultsObject.set(accessToken, forKey: ACCESS_TOKEN)
                userDefaultsObject.set(tokenType, forKey: TOKEN_TYPE)
                userDefaultsObject.set(true, forKey: IS_USER_LOGGED_IN)
                completionBlock(true)
                
            } else {
                completionBlock(false)
            }
        }
    }
    func fetchWordsFromCoreData() {
        let fetchRequest: NSFetchRequest<WordDetails> = WordDetails.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateUpdated", ascending: false, selector: nil)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            WordsViewController.words = try PersistenceService.context.fetch(fetchRequest)
        } catch {
        }
    }
    
    func addButtonCustomization() {
        this.addButtonUIButton = UIButton(type: .custom)
        this.addButtonUIButton.frame = CGRect(x: self.view.frame.maxX * 4.9/6, y: self.view.frame.maxY * 4.9/6, width: 50, height: 50)
        this.addButtonUIButton.clipsToBounds = true
        this.addButtonUIButton.titleLabel?.adjustsFontSizeToFitWidth = true
        this.addButtonUIButton.tintColor = #colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)
        this.addButtonUIButton.layer.backgroundColor = #colorLiteral(red: 0.9329633117, green: 0.491658628, blue: 0.2886041999, alpha: 1)
        this.addButtonUIButton.layer.isOpaque = true
        this.addButtonUIButton.layer.cornerRadius = this.addButtonUIButton.frame.width / 2
        this.addButtonUIButton.dropShadow(color: #colorLiteral(red: 0.9417235255, green: 0.7750624418, blue: 0.6908532977, alpha: 1), opacity: 1, radius: 6, offset: CGSize(width: 0, height: 4))
        this.addButtonUIButton.titleLabel?.font = UIFont.init(name: "KohinoorTelugu-Regular", size: 40)
        this.addButtonUIButton.setTitle("+", for: UIControlState.normal)
        this.addButtonUIButton.addTarget(self, action: #selector(addButtonPressed), for: UIControlEvents.touchUpInside)
    }
    
    fileprivate func handleFetchingWords() {
        if let userLoggedIn = isUserAlreadyLoggedIn {
            if  userLoggedIn {
                //spinner view
                let spinnerView = MBProgressHUD.showAdded(to: self.navigationController?.view ?? self.view, animated: true)
                spinnerView.label.text = "Loading..."
                getWords() { [weak self] (success, error, _) in
                    guard let strongSelf = self else {return}
                    if success {
                        DispatchQueue.main.async {
                            strongSelf.fetchWordsFromCoreData()
                            strongSelf.handleGettingWeekValues()
                            strongSelf.arrangeWordsByWeek()
                            UIView.transition(with: strongSelf.wordsTableView,
                                              duration: 0.35,
                                              options: .transitionCrossDissolve,
                                              animations: { strongSelf.wordsTableView.reloadData() })
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
    
    fileprivate func arrangeWordsByWeek() {
        wordsByWeek = [:]
        for (index, fromToMilliseconds) in sectionHeaders.millis.enumerated() {
            wordsByWeek[index] = WordsViewController.words.filter { (word) -> Bool in
                switch word.dateUpdated {
                case fromToMilliseconds.from ... fromToMilliseconds.to : return true
                default : return false
                }
            }
        }
    }
    
    fileprivate func handleGettingWeekValues() {
        let fromDate = WordsViewController.words.last?.dateUpdated
        let toDate = WordsViewController.words.first?.dateUpdated
        print(fromDate as Any)
        print(toDate as Any)
        var value: (stringRep: [(from: String, to: String)], millis: [(from: TimeInterval, to: TimeInterval)]) = ([], [])
        if let fromDate = fromDate, let toDate = toDate {
            value = Date.totalNumberOfWeeksRoundOffByWeekends(From: fromDate, To: toDate)
        }
        sectionHeaders = value
    }
}

// to handle all the objective functions
extension WordsViewController {
    @objc func newWordAdded() {
        fetchWordsFromCoreData()
        arrangeWordsByWeek()
        UIView.transition(with: self.wordsTableView, duration: 0.35, options: .transitionCrossDissolve, animations: {self.wordsTableView.reloadData()}, completion: nil)
    }
    @objc func pullToRefreshHandler() {
        // firebase reports - tracks how many times the user pulls to refresh
        Analytics.logEvent("pulledToRefresh", parameters: nil)
        
        guard let latestWordAdded = WordsViewController.words.first else {
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
                    strongSelf.arrangeWordsByWeek()
                    strongSelf.wordsTableView.reloadData()
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
                                    strongSelf.wordsTableView.reloadData()
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
    @objc func addButtonPressed(){
        let wordsViewController = self.storyboard?.instantiateViewController(withIdentifier: "newwordviewcontroller") as? NewWordViewController
        wordsViewController?.userName = userName
        self.present(wordsViewController!, animated: true, completion: nil)
    }
}

class WordsTableViewCell: UITableViewCell {
    @IBOutlet weak var wordMeaningContainerView: UIView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    var word: String?
    var meaning: String?
    var wordAddedBy: String?
    var source: String?
    var dateAdded: Double?
    var dateUpdated: Double?
    var userId: String?
}
