//
//  NoGoViewController.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 11/9/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

class NoGoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var newNoGo:NoGoSaving?
    
    var tempArrayOfPlaces:[SavePlacesObject] = []
    
    var deleteAllBarButton:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        deleteAllBarButton = UIBarButtonItem(title: "Delete All", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.deleteAllOnClick))
        self.navigationItem.rightBarButtonItem = deleteAllBarButton!
        deleteAllBarButton?.tintColor = UIColor.red
        
        newNoGo = NoGoSaving()
        self.reloadData()
    }
    
    @objc func deleteAllOnClick(){
        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete all?", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (action) in
            self.newNoGo!.removeArrayOfPlaces()
            self.reloadData()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func reloadData(){
        self.newNoGo!.loadArrayOfPlaces()
        self.tempArrayOfPlaces = OptionsSingleton.sharedInstance.tempArrayOfNoGoPlaces
        self.mainTableView.reloadData()
        
        
        if(tempArrayOfPlaces.count == 0){
            deleteAllBarButton?.isEnabled = false
        }else{
            deleteAllBarButton?.isEnabled = true
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrefNoGoKeyCell") as? PreferredNoGoKeywordsTableViewCell

        
        cell?.mainLabel.text = tempArrayOfPlaces[indexPath.row].name!
        cell?.priceLabel.text = "Price \(tempArrayOfPlaces[indexPath.row].price!)"
        cell?.ratingLabe.text = "Rating \(Int(tempArrayOfPlaces[indexPath.row].rating!))"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tempArrayOfPlaces.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "What would you like to do?", message: "Select what you would like to do.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let deleteButton = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (action) in
            self.newNoGo!.removeSinglePlace(place: self.tempArrayOfPlaces[indexPath.row])
            self.reloadData()
        }
        let viewButton = UIAlertAction(title: "View", style: UIAlertActionStyle.default) { (action) in
            
        }
        let moveToNoGo = UIAlertAction(title: "Move to Preferred List", style: UIAlertActionStyle.default) { (action) in
            self.newNoGo?.saveToPreferred(itemToMoveToPreferred: self.tempArrayOfPlaces[indexPath.row])
            self.reloadData()
            
        }
        alert.addAction(viewButton)
        alert.addAction(moveToNoGo)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }

}
