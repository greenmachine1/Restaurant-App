//
//  NoGoSaving.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 11/9/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnSaveOfNoGoPlaces{
    func removeStatusNoGo(status:String)
}

class NoGoSaving: NSObject {
    
    var passedInRestaurant:SavePlacesObject?
    var tempArrayOfRestaurants:[SavePlacesObject] = []
    
    var delegate:ReturnSaveOfNoGoPlaces?
    
    init(info:SavePlacesObject) {
        let newSavedObject:SavePlacesObject = SavePlacesObject(_name: info.name!, _location: info.location!, _open: info.open!, _price: info.price!, _rating: info.rating!, _distanceFromUser: info.distanceFromUser!)
        
        passedInRestaurant = newSavedObject
    }
    
    override init() {
        super.init()
    }
    
    func saveArrayOfPlaces(){
        // first gotta see if there is existing data first //
        if let existingData = UserDefaults.standard.object(forKey: "noGoPlacesArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [SavePlacesObject]{
                
                // saving it to the temp array to work with //
                tempArrayOfRestaurants = placesArray
                
                var exists = false
                for items in tempArrayOfRestaurants{
                    if(items.name == passedInRestaurant?.name && items.price == passedInRestaurant?.price){
                        exists = true
                    }
                }
                if(exists == false){
                    
                    // saving a new place to the existing //
                    tempArrayOfRestaurants.append(passedInRestaurant!)
                    
                    // saving the array to the archive //
                    let placeSave = NSKeyedArchiver.archivedData(withRootObject: tempArrayOfRestaurants)
                    UserDefaults.standard.set(placeSave, forKey: "noGoPlacesArray")

                }
                
            }
            // if the placesArray key doesnt exist, then we need to create one //
        }else{
            // saving a new place to the existing //
            tempArrayOfRestaurants.append(passedInRestaurant!)
            
            // saving the array to the archive //
            let placeSave = NSKeyedArchiver.archivedData(withRootObject: tempArrayOfRestaurants)
            UserDefaults.standard.set(placeSave, forKey: "noGoPlacesArray")
        }
    }
    
    func existsInPreferred(itemToCheck:SavePlacesObject) ->(Bool, Int){
        var exists = false
        var index = 0
        // first gotta see if there is existing data first //
        if let existingData = UserDefaults.standard.object(forKey: "placesArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [SavePlacesObject]{
                
                for (_index, _items) in placesArray.enumerated(){
                    if(_items.name == itemToCheck.name && (_items.location?.coordinate.latitude == itemToCheck.location?.coordinate.latitude) && (_items.location?.coordinate.longitude == itemToCheck.location?.coordinate.longitude)){
                        exists = true
                        index = _index
                    }
                }
            }
        }
        return (exists, index)
    }
    
    // removes the entire thing //
    func removeArrayOfPlaces(){
        tempArrayOfRestaurants.removeAll()
        UserDefaults.standard.removeObject(forKey: "noGoPlacesArray")
        
    }
    
    // removes a single entry //
    func removeSinglePlace(place:SavePlacesObject){
        if let existingData = UserDefaults.standard.object(forKey: "noGoPlacesArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [SavePlacesObject]{
                
                // loading the places array into the options singleton for //
                // use over there
                tempArrayOfRestaurants = placesArray
                
                // searching throug the array for our place that was passed in //
                for (index, items) in tempArrayOfRestaurants.enumerated(){
                    let name = items.name
                    let nameOfPlacePassedIn = place.name
                    if(name == nameOfPlacePassedIn){
                        tempArrayOfRestaurants.remove(at: index)
                    }
                }
                
                // saving the array to the archive //
                let placeSave = NSKeyedArchiver.archivedData(withRootObject: tempArrayOfRestaurants)
                UserDefaults.standard.set(placeSave, forKey: "noGoPlacesArray")
            }
            
        }
    }
    
    func saveToPreferred(itemToMoveToPreferred:SavePlacesObject){
        
        var arrayOfPreferredPlaces:[SavePlacesObject] = []
        var arrayOfNoGoPlaces:[SavePlacesObject] = []
        if let existingDataPreferred = UserDefaults.standard.object(forKey: "placesArray") as? NSData{
            if let placesArrayPreferred = NSKeyedUnarchiver.unarchiveObject(with: existingDataPreferred as Data) as? [SavePlacesObject]{
                arrayOfPreferredPlaces = placesArrayPreferred
            }
        }
        
        if let existingDataNoGo = UserDefaults.standard.object(forKey: "noGoPlacesArray") as? NSData{
            if let placesArrayNoGo = NSKeyedUnarchiver.unarchiveObject(with: existingDataNoGo as Data) as? [SavePlacesObject]{
                arrayOfNoGoPlaces = placesArrayNoGo
            }
        }

        // saving to the array of no go places //
        arrayOfPreferredPlaces.append(itemToMoveToPreferred)
            
        // saving the array to the archive //
        let placeSave = NSKeyedArchiver.archivedData(withRootObject: arrayOfPreferredPlaces)
        UserDefaults.standard.set(placeSave, forKey: "placesArray")
            
        // removing item from placesArray //
        self.removeSinglePlace(place: itemToMoveToPreferred)
            
         OptionsSingleton.sharedInstance.updateDidChangeOptions()
    }
    
    
    func returnArrayOfPlaces() ->[SavePlacesObject]{
        if let existingData = UserDefaults.standard.object(forKey: "noGoPlacesArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [SavePlacesObject]{
                // loading the places array into the options singleton for //
                // use over there
                tempArrayOfRestaurants = placesArray
                
                 OptionsSingleton.sharedInstance.updateDidChangeOptions()
                
                return tempArrayOfRestaurants
            }
        }
        return []
    }
    
    
    // loads the array into the options singleton //
    func loadArrayOfPlaces(){
        // need to pass this on to the OptionsSingleton to load up in the options //
        // view controller //
        
        if let existingData = UserDefaults.standard.object(forKey: "noGoPlacesArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [SavePlacesObject]{
                
                // loading the places array into the options singleton for //
                // use over there
                tempArrayOfRestaurants = placesArray

                OptionsSingleton.sharedInstance.listOfNoGoPlacesAddToOptionsView(list: tempArrayOfRestaurants)
                
                // giving feedback to the user //
                self.delegate?.removeStatusNoGo(status: "Load Complete!")
            }
            // if the placesArray doesnt exist, send back an empty array //
        }else{
            OptionsSingleton.sharedInstance.listOfNoGoPlacesAddToOptionsView(list: [])
        }
    }
}
