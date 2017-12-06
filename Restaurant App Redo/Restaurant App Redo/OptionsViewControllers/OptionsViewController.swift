//
//  OptionsViewController.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/20/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//


/*

 The saved list will always be on 
 1. the saved items will get involved with the search results based on what they are - so
    if the user has pizza hut in their saved list, it will only show up on the search results
    if they search for something similar and will always be at the top of the list with a star.
 
 
 
*/




import UIKit

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReturnKeywordsDelegate{

    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var ratingSegmentControl: UISegmentedControl!
    @IBOutlet weak var priceSegmentControll: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        milesLabel.text = "5 Mile"

        let undoButton:UIBarButtonItem = UIBarButtonItem(title: "Undo", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.barButtonSelected))
    
        self.navigationItem.rightBarButtonItem = undoButton
        
        self.loadUserDefaults()
    }
    
    func loadUserDefaults(){

        let _valueForDistance = OptionsSingleton.sharedInstance.getDistance()
        distanceSlider.setValue(Float(_valueForDistance), animated: true)
        
        milesLabel.text = "\(_valueForDistance) Miles"
    
        let _valueForPrices = OptionsSingleton.sharedInstance.getPrice()
        priceSegmentControll.selectedSegmentIndex = _valueForPrices
        
        
        let _valueForRating = OptionsSingleton.sharedInstance.getRating()
        ratingSegmentControl.selectedSegmentIndex = _valueForRating
        
    }

    @objc func barButtonSelected(){
        OptionsSingleton.sharedInstance.deleteAllOptions()
        loadUserDefaults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordsCell") as! KeywordsTableViewCell
            cell.mainLabel.text = "Keywords"
            return cell
        }else if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordsCell") as! KeywordsTableViewCell
            cell.mainLabel.text = "Saved Places"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordsCell") as! KeywordsTableViewCell
            cell.mainLabel.text = "Blocked Places"
            return cell
        }
    }
    
    // will be injecting different sets of data into each of the same table views //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            // keywords //
            let keywordsView = self.storyboard?.instantiateViewController(withIdentifier: "Keywords") as! KeywordsViewController
            keywordsView.delegate = self
            self.navigationController?.pushViewController(keywordsView, animated: true)
            
        }else if(indexPath.row == 1){
            
            // preferred //
            let preferredView = self.storyboard?.instantiateViewController(withIdentifier: "PrefNoGoKey") as! PreferredNoGoViewController
            
            self.navigationController?.pushViewController(preferredView, animated: true)
            
        }else{
            // no go //
            let noGoView = self.storyboard?.instantiateViewController(withIdentifier: "NoGo") as! NoGoViewController
            self.navigationController?.pushViewController(noGoView, animated: true)
        }
    }
    
    func returnKeywords(keywords: [String]) {
        // saving the keywords //
        OptionsSingleton.sharedInstance.setKeyWords(keywords: keywords)
    }
    
    
    
    
    @IBAction func distanceSliderDidChange(_ sender: UISlider) {
            let distanceValue = sender.value
        milesLabel.text = "\(Int(sender.value)) Miles"
        OptionsSingleton.sharedInstance.setDistance(distance: Int(distanceValue))
    }
    
    @IBAction func segmentDidChangeValue(_ sender: UISegmentedControl) {
        if(sender.tag == 0){
            // price //
            // need the rating to be 0 - 4
            OptionsSingleton.sharedInstance.setPrice(price: sender.selectedSegmentIndex)
            
        }else if(sender.tag == 1){

        }else if(sender.tag == 2){
            // rating //
            // need the rating to be 1 - 5 //
            OptionsSingleton.sharedInstance.setRating(rating: sender.selectedSegmentIndex)
        }
    }
}
