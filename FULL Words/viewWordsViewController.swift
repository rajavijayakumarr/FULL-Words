//
//  viewWordsViewController.swift
//  FULL Words
//
//  Created by User on 25/04/18.
//  Copyright © 2018 FULL. All rights reserved.
//

import UIKit

class viewWordsViewController: UIViewController {
    @IBOutlet weak var nameOfTheWordLabel: UILabel!
    @IBOutlet weak var meaningOfTheWordLabel: UILabel!
    @IBOutlet weak var sourceOfTheWordLabel: UILabel!
    @IBOutlet weak var wordAddedByLabel: UILabel!
    @IBOutlet weak var wordAndMeaningView: UIView!
    @IBOutlet weak var sourceView: UIView!
    @IBOutlet weak var wordAddedByView: UIView!
    
    var nameOfWord: String?
    var meaningOfWord: String?
    var sourceOfWord: String?
    var wordAddedBy: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.visibleViewController?.navigationItem.title = "Details of the word"
        self.navigationController?.visibleViewController?.navigationItem.setHidesBackButton(false, animated: false)
        nameOfTheWordLabel.text = nameOfWord! + ":"
        meaningOfTheWordLabel.text = meaningOfWord
        sourceOfTheWordLabel.text = sourceOfWord
        wordAddedByLabel.text = wordAddedBy
        makeCornerRadiusAndDropShadowForAllTheSubView()
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.visibleViewController?.navigationItem.setHidesBackButton(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func makeCornerRadiusAndDropShadowForAllTheSubView() {
        
        wordAndMeaningView.dropShadow(color: .black, opacity: 1, radius: 5)
        sourceView.dropShadow(color: .black, opacity: 1, radius: 5)
        wordAddedByView.dropShadow(color: .black, opacity: 1, radius: 5)

        wordAndMeaningView.layer.cornerRadius = 25
        sourceView.layer.cornerRadius = 25
        wordAddedByView.layer.cornerRadius = 25
    }
}

///to make a uiview drop a shadow in side bottom and top
extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, radius: CGFloat = 1) {
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
//        layer.shadowOffset = CGSize.zero
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = radius
    }
}
