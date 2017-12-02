//
//  KeywordsViewController.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 11/4/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnKeywordsDelegate{
    func returnKeywords(keywords:[String])
}

class KeywordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mainTableView: UITableView!
    
    var arrayOfKeywordsToSendBack:[String] = []
    
    var keywords = ["Pizza", "Burgers", "Chinese", "Mexican", "Chicken", "Italian", "Thai", "BBQ","Asian", "Cuban", "German", "Hawiian", "Cajun", "Seafood", "Healthy", "Tapas", "Indian", "English", "Lunch", "Dinner", "Breakfast", "Brunch", "Greek", "Ice+Cream", "Spaghetti", "Japanese", "Sandwiches", "Vietnamese", "Korean", "Phillippian", "Vegetarian", "Sushi", "Steak", "Pie", "Cake"]
    
    var delegate:ReturnKeywordsDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        let undoButton:UIBarButtonItem = UIBarButtonItem(title: "Undo", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.undoButtonOnClick))
        self.navigationItem.rightBarButtonItem = undoButton
        
        arrayOfKeywordsToSendBack = OptionsSingleton.sharedInstance.getKeywords()

        for (index, item) in self.keywords.enumerated(){
            for keywords in self.arrayOfKeywordsToSendBack{
                if(keywords == item){
                    self.mainTableView.selectRow(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
                }
            }
        }
       
    }
    
    @objc func undoButtonOnClick(){
        arrayOfKeywordsToSendBack.removeAll()
        self.delegate?.returnKeywords(keywords: arrayOfKeywordsToSendBack)
        self.mainTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        arrayOfKeywordsToSendBack.append(keywords[indexPath.row])
        self.delegate?.returnKeywords(keywords: arrayOfKeywordsToSendBack)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        for (index, item) in arrayOfKeywordsToSendBack.enumerated(){
            if(item == keywords[indexPath.row]){
                self.arrayOfKeywordsToSendBack.remove(at: index)
            }
        }
        self.delegate?.returnKeywords(keywords: arrayOfKeywordsToSendBack)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Keywords") as? KeywordsTableViewCell
        cell?.mainLabel.text = keywords[indexPath.row]
        return cell!
    }
    


}
