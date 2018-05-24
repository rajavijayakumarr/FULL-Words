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
    var words = [WordDetails]()
    
    //this is the name of the notification that will reload the table data if any new word is added in the newWordViewController
    let wordAdded = "newWordAddedForWOrds"

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let greenColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = greenColor
        self.navigationController?.navigationBar.barTintColor = greenColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) as Any]
        self.navigationController?.view.tintColor = #colorLiteral(red: 0.2419127524, green: 0.6450607777, blue: 0.9349957108, alpha: 1)
        navigationController?.visibleViewController?.navigationItem.title = "Words"

        let window = UIApplication.shared.keyWindow
        window?.addSubview(this.addButtonUIButton)

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
        cell.wordLabel.text = words[indexPath.item].nameOfWord?.capitalizingFirstLetter()
        cell.word = words[indexPath.item].nameOfWord?.capitalizingFirstLetter()
        cell.wordAddedBy = userName!
        cell.cardView.layer.cornerRadius = 5
        cell.cardView.dropShadow(color: .black, opacity: 0.3, radius: 0.5)
        
        cell.source = words[indexPath.item].sourceOfWord
        cell.meaningLabel.text = words[indexPath.item].meaningOfWord
        cell.meaning = words[indexPath.item].meaningOfWord
        return cell
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        print("current offset: " + "\(currentOffset)")
        if maximumOffset - currentOffset <= self.view.bounds.height * 1/4 {
            //spinner
            print("called when the user drags to the botton")
            print(maximumOffset - currentOffset)
            
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return words.count
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
        
        self.navigationController?.pushViewController(wordsViewController!, animated: true)
        
    }
    
    func fetchWordsFromCoreData() {
        let fetchRequest: NSFetchRequest<WordDetails> = WordDetails.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateUpdated", ascending: false, selector: nil)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            words = try PersistenceService.context.fetch(fetchRequest)
        } catch {
        }
    }
    
    @objc func pullToRefreshHandler() {
        guard let latestWordAdded = words.first else {
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

extension WordsTableViewController {
    @objc func newWordAdded() {
        fetchWordsFromCoreData()
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

