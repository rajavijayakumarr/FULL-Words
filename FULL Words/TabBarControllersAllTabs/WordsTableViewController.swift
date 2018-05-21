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


class WordsTableViewController: UITableViewController {
    typealias this = WordsTableViewController
    
    static var addButtonUIButton: UIButton!
    var userName: String?
    var userLoggedIn: Bool?
    var spinnerView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var wordsOfUserValues = [WordDetails]()
    let newWOrdAdded = "newWordAddedForWOrds"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userLoggedIn = userLoggedIn {

            if  userLoggedIn {
                let rightBarButton = UIBarButtonItem(customView: spinnerView)
                self.navigationController?.visibleViewController?.navigationItem.setRightBarButton(rightBarButton, animated: true)
                spinnerView.startAnimating()
                getTheWordsAddedByTheUserFromServer("first request")
            } else {
                addTheWordsToThePersistantContainer()
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100

        let name = NSNotification.Name.init(rawValue: newWOrdAdded)
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
        cell.addedWordLabel.text = wordsOfUserValues[indexPath.item].nameOfWord?.capitalizingFirstLetter()
        cell.addedWord = wordsOfUserValues[indexPath.item].nameOfWord?.capitalizingFirstLetter()
        cell.addedBy = userName!
        cell.viewOfAddedWordsCell.layer.cornerRadius = 5
        cell.viewOfAddedWordsCell.dropShadow(color: .black, opacity: 0.3, radius: 0.5)
        
        cell.sourceForTheWord = wordsOfUserValues[indexPath.item].sourceOfWord
        cell.meaningLabel.text = wordsOfUserValues[indexPath.item].meaningOfWord
        cell.meaningOfTheWord = wordsOfUserValues[indexPath.item].meaningOfWord
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return wordsOfUserValues.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
    
    func addTheWordsToThePersistantContainer() {
        let fetchRequest: NSFetchRequest<WordDetails> = WordDetails.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateUpdated", ascending: false, selector: nil)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            wordsOfUserValues = try PersistenceService.context.fetch(fetchRequest)
        } catch {
        }
    }
    
    func getTheWordsAddedByTheUserFromServer(_ cursorValue: String) {
        
        var cursorValue = cursorValue
        
        if cursorValue != ""{
        let accessToken = userValues.value(forKey: ACCESS_TOKEN) as! String
        let tokenType = userValues.value(forKey: TOKEN_TYPE) as! String
            var requestForGettingUserWOrds = URLRequest(url: URL(string: FULL_WORDS_SCOPE_URL_TO_GET_ALL_WORDS + (cursorValue == "first request" ? "" : cursorValue ))!)
            print("*************************************************")
            print(FULL_WORDS_SCOPE_URL_TO_GET_ALL_WORDS + cursorValue)
            print("*************************************************")
        requestForGettingUserWOrds.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")
        requestForGettingUserWOrds.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestForGettingUserWOrds.httpMethod = "GET"
        
        Alamofire.request(requestForGettingUserWOrds).responseJSON { (responseData) in
            if responseData.error == nil  {
                print("*******************************************************")
                print(String(data: responseData.data!, encoding: String.Encoding.utf8) as Any)
                let responseJSON_Data = JSON(responseData.data!)
                cursorValue = responseJSON_Data["data"]["cursor"].stringValue
                if responseJSON_Data["response"].boolValue {
                    let arrayOfUserWords = responseJSON_Data["data"]["words"].arrayValue
                    print(cursorValue)
                    for wordValues in arrayOfUserWords {
                        let wordDetails = WordDetails(context: PersistenceService.context)
                        wordDetails.dateAdded = wordValues["createdAt"].doubleValue
                        wordDetails.dateUpdated = wordValues["updatedAt"].doubleValue
                        wordDetails.nameOfWord = wordValues["word"].stringValue
                        wordDetails.sourceOfWord = wordValues["src"].stringValue
                        wordDetails.meaningOfWord = wordValues["desc"].stringValue
                        wordDetails.wordAddedBy = self.userName
                        wordDetails.userId = wordValues["userId"].stringValue
                        PersistenceService.saveContext()
                    }
                    self.addTheWordsToThePersistantContainer()
                    UIView.transition(with: self.tableView,
                                      duration: 0.35,
                                      options: .transitionCrossDissolve,
                                      animations: { self.tableView.reloadData() })
               //     self.tableView.reloadData()
                    self.getTheWordsAddedByTheUserFromServer(cursorValue)
                    
                } else {
                    let message = responseJSON_Data["msg"].stringValue
                    let error = responseJSON_Data["error"].stringValue
                    let alert = UIAlertController(title: message, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.navigationItem.setRightBarButton(nil, animated: true)
                    self.spinnerView.stopAnimating()
                    self.spinnerView.removeFromSuperview()
                }
            } else {
                let alert = UIAlertController(title: "error", message: "Something went wrong while fetching the user words", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.navigationController?.navigationItem.setRightBarButton(nil, animated: true)
                self.spinnerView.stopAnimating()
                self.spinnerView.removeFromSuperview()
            }
        }
        } else {
            self.navigationController?.navigationItem.setRightBarButton(nil, animated: true)
            self.spinnerView.stopAnimating()
            self.spinnerView.removeFromSuperview()
        }
        
}
}

extension WordsTableViewController {
    @objc func newWordAdded() {
        addTheWordsToThePersistantContainer()
        
        UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
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
