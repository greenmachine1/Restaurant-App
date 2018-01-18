//
//  PopUpSearchView.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 1/8/18.
//  Copyright © 2018 Cory Green. All rights reserved.
//

import UIKit
import MapKit

@objc protocol ReturnSearchPopUpViewDelegate{
    func doneButtonClicked()
    func sendBackAlert(title:String, alertString:String)
    func sendBackInfo(title:String, location:CLLocation)
}

class PopUpSearchView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate:ReturnSearchPopUpViewDelegate?
    var doneButton:UIButton?
    var mainTextField:UITextField?
    var mainListView:UITableView?
    var arrayOfPreviouslyLookedUpLocations:[searchLocation] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    func drawPopUpView(){
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        
        doneButton = UIButton(frame: CGRect(x: self.frame.size.width - 110, y: 10, width: 100, height: 30))
        doneButton!.setTitle("Done", for: UIControlState.normal)
        doneButton!.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton!.addTarget(self, action: #selector(self.doneButtonOnClick), for: UIControlEvents.touchUpInside)
        doneButton!.backgroundColor = Colors.sharedInstance.lightBlue
        doneButton!.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        
        doneButton!.layer.cornerRadius = 5.0
        doneButton!.clipsToBounds = true
        self.addSubview(doneButton!)
        
        
        mainTextField = UITextField(frame: CGRect(x: 10, y: (self.doneButton?.frame.origin.y)! + ((self.doneButton?.frame.size.height)! + 10), width: self.frame.size.width - 20, height: 30))
        mainTextField?.delegate = self
        mainTextField?.layer.cornerRadius = 5.0
        mainTextField?.clipsToBounds = true
        mainTextField?.backgroundColor = UIColor.white
        mainTextField?.placeholder = "Search for a new default location."
        
        self.addSubview(mainTextField!)
        
        
        let historyLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: (self.mainTextField?.frame.size.width)!, height: 30))
        historyLabel.center = CGPoint(x: (self.mainTextField?.center.x)!, y: (self.mainTextField?.center.y)! + 30)
        historyLabel.text = "Location History"
        historyLabel.textAlignment = .center
        historyLabel.textColor = Colors.sharedInstance.lightBlue
        
        self.addSubview(historyLabel)
        
        mainListView = UITableView(frame: CGRect(x: 10, y: (historyLabel.frame.origin.y) + (historyLabel.frame.size.height) + 10, width: self.frame.size.width - 20, height: 200), style: UITableViewStyle.plain)
        mainListView?.register(ListViewTableViewCell.self, forCellReuseIdentifier: "searchCell")
        self.mainListView?.delegate = self
        self.mainListView?.dataSource = self
        self.mainListView?.backgroundColor = UIColor.clear
        self.mainListView?.layer.cornerRadius = 5.0
        self.mainListView?.clipsToBounds = true
        self.mainListView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        self.mainListView?.isOpaque = true
        
        
        self.addSubview(mainListView!)
    }
    
    func scrollToTopOfList(){
        self.mainListView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.loadArrayOfPlacesFromHistory().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! ListViewTableViewCell
        for views in cell.contentView.subviews{
            views.removeFromSuperview()
        }
            cell.mainLabel?.text = self.arrayOfPreviouslyLookedUpLocations[indexPath.row]._name!
            cell.starImage?.image = UIImage(named: "NewCenterIcon")
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newLocationInfo = arrayOfPreviouslyLookedUpLocations[indexPath.row]

        self.delegate?.sendBackInfo(title: newLocationInfo._name!, location: newLocationInfo._location!)
    }
    
    
    func placeSelectedAndShouldBeAddedToHistory(name:String, location:CLLocation){
        
        let newLocationToBeAdded:searchLocation = searchLocation(name: name, location: location)
        if(self.checkToSeeIfItemExistsInHistory(itemToCheck: newLocationToBeAdded) == false){
            self.arrayOfPreviouslyLookedUpLocations.insert(newLocationToBeAdded, at: 0)
            if(self.arrayOfPreviouslyLookedUpLocations.count > 4){
                self.arrayOfPreviouslyLookedUpLocations.removeLast()
            }
            
            // need to save the array to user defaults //
            self.saveArrayOfPlacesToHistory()
        
            self.mainListView?.reloadData()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(!(textField.text == "")){
            self.searchForLocationByTextEntry(text: textField.text!)
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    func searchForLocationByTextEntry(text:String){
        let search = MKLocalSearchRequest()
        search.naturalLanguageQuery = text
        let localSearch = MKLocalSearch(request: search)
        localSearch.start { (searchResponse, error) in
            if(searchResponse == nil){
                // send out a notification that the place was not found //
                self.delegate?.sendBackAlert(title: "No Result Found.", alertString: "Please Try Again.")
            }else{
                let location = CLLocation(latitude: (searchResponse?.boundingRegion.center.latitude)!, longitude: (searchResponse?.boundingRegion.center.longitude)!)
                self.delegate?.sendBackInfo(title: text, location: location)
            }
        }
    }
    
    @objc func doneButtonOnClick(){
        self.mainTextField?.resignFirstResponder()
        self.delegate?.doneButtonClicked()
        
    }
    
    
    // saving and retreiving history data //
    func saveArrayOfPlacesToHistory(){
        // saving the array to the archive //
        let placeSave = NSKeyedArchiver.archivedData(withRootObject: arrayOfPreviouslyLookedUpLocations)
        UserDefaults.standard.set(placeSave, forKey: "searchArray")
    }
    
    
    func deleteHistory(){
        UserDefaults.standard.removeObject(forKey: "searchArray")
    }
    
    func checkToSeeIfItemExistsInHistory(itemToCheck:searchLocation) ->Bool{
        var tempBoolStatement = false
        if let existingData = UserDefaults.standard.object(forKey: "searchArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [searchLocation]{
                for items in placesArray{
                    if(itemToCheck._name == items._name){
                        tempBoolStatement = true
                    }
                }
            }
        }
        return tempBoolStatement
    }
    
    
    func loadArrayOfPlacesFromHistory()->[searchLocation]{
        if let existingData = UserDefaults.standard.object(forKey: "searchArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [searchLocation]{
                arrayOfPreviouslyLookedUpLocations = placesArray
            }
        }
        return arrayOfPreviouslyLookedUpLocations
    }
}


// small object used to store location name and location //
class searchLocation:NSObject, NSCoding{
    
    var _name:String?
    var _location:CLLocation?

    init(name:String, location:CLLocation) {
        _name = name
        _location = location
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_location, forKey: "Location")
        aCoder.encode(_name, forKey: "Name")
    }
    required init?(coder aDecoder: NSCoder) {
        self._name = (aDecoder.decodeObject(forKey: "Name") as! String)
        self._location = (aDecoder.decodeObject(forKey: "Location") as! CLLocation)
    }
    

}
