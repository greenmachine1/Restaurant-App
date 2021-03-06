//
//  PreferredNoGoSaving.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 11/4/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnSaveOfPreferredPlaces{
    func removeStatus(status:String)
}

class PreferredNoGoSaving: NSObject{
    
    var passedInRestaurant:SavePlacesObject?
    var tempArrayOfRestaurants:[SavePlacesObject] = []
    
    var delegate:ReturnSaveOfPreferredPlaces?
    
    init(info:SavePlacesObject) {
        
        let newSavedObject:SavePlacesObject = SavePlacesObject(_name: info.name!, _location: info.location!, _open: info.open!, _price: info.price!, _rating: info.rating!, _distanceFromUser: info.distanceFromUser!, _isSaved: false, _isBlocked: false)
        
        passedInRestaurant = newSavedObject
    }
    
    override init() {
        super.init()
    }

    func saveArrayOfPlaces(){
        // first gotta see if there is existing data first //
        if let existingData = UserDefaults.standard.object(forKey: "placesArray") as? NSData{
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

                    passedInRestaurant?.setIsSaved(save: true)
                    passedInRestaurant?.setIsBlocked(blocked: false)
                    
                    // saving a new place to the existing //
                    tempArrayOfRestaurants.append(passedInRestaurant!)
                    
                    OptionsSingleton.sharedInstance.addSavedItemToMainArray(itemToAdd: passedInRestaurant!)
                
                    // saving the array to the archive //
                    let placeSave = NSKeyedArchiver.archivedData(withRootObject: tempArrayOfRestaurants)
                    UserDefaults.standard.set(placeSave, forKey: "placesArray")
                }
                
            }
        // if the placesArray key doesnt exist, then we need to create one //
        }else{
            
            passedInRestaurant?.setIsSaved(save: true)
            passedInRestaurant?.setIsBlocked(blocked: false)
            
            // saving a new place to the existing //
            tempArrayOfRestaurants.append(passedInRestaurant!)
            
            OptionsSingleton.sharedInstance.addSavedItemToMainArray(itemToAdd: passedInRestaurant!)
            
            // saving the array to the archive //
            let placeSave = NSKeyedArchiver.archivedData(withRootObject: tempArrayOfRestaurants)
            UserDefaults.standard.set(placeSave, forKey: "placesArray")
        }
    }
    
    
    
    
    
    
    // checking to see if the preferred item exists in the no go list //
    func existsInNoGo(itemToCheck:SavePlacesObject) ->(Bool, Int){
        var exists = false
        var index = 0
        // first gotta see if there is existing data first //
        if let existingData = UserDefaults.standard.object(forKey: "noGoPlacesArray") as? NSData{
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
        UserDefaults.standard.removeObject(forKey: "placesArray")
        
    }
    
    // removes a single entry //
    func removeSinglePlace(place:SavePlacesObject){
        if let existingData = UserDefaults.standard.object(forKey: "placesArray") as? NSData{
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
                        
                        // removing the item from the main list //
                        OptionsSingleton.sharedInstance.removeSaveItemFromMainList(itemToRemove: items)
                    }
                }

                // saving the array to the archive //
                let placeSave = NSKeyedArchiver.archivedData(withRootObject: tempArrayOfRestaurants)
                UserDefaults.standard.set(placeSave, forKey: "placesArray")
            }
            
        }
    }
    
    
    func saveToNoGo(itemToMoveToNoGo:SavePlacesObject){
        var arrayOfNoGoPlaces:[SavePlacesObject] = []

        if let existingDataNoGo = UserDefaults.standard.object(forKey: "noGoPlacesArray") as? NSData{
            if let placesArrayNoGo = NSKeyedUnarchiver.unarchiveObject(with: existingDataNoGo as Data) as? [SavePlacesObject]{
                arrayOfNoGoPlaces = placesArrayNoGo
            }
        }

        itemToMoveToNoGo.setIsSaved(save: false)
        itemToMoveToNoGo.setIsBlocked(blocked: true)
        
        // removing the item from the main list //
        OptionsSingleton.sharedInstance.removeSaveItemFromMainList(itemToRemove: itemToMoveToNoGo)
        
        
        // saving to the array of no go places //
        arrayOfNoGoPlaces.append(itemToMoveToNoGo)
            
        // saving the array to the archive //
        let placeSave = NSKeyedArchiver.archivedData(withRootObject: arrayOfNoGoPlaces)
        UserDefaults.standard.set(placeSave, forKey: "noGoPlacesArray")
            
        // removing item from placesArray //
        self.removeSinglePlace(place: itemToMoveToNoGo)
            
        //OptionsSingleton.sharedInstance.updateDidChangeOptions()
    }
    
    // loads the array into the options singleton //
    func loadArrayOfPlaces(){
        // need to pass this on to the OptionsSingleton to load up in the options //
        // view controller //
        
        if let existingData = UserDefaults.standard.object(forKey: "placesArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [SavePlacesObject]{
                
                // loading the places array into the options singleton for //
                // use over there //
                tempArrayOfRestaurants = placesArray
                OptionsSingleton.sharedInstance.listOfPrefferedPlacesAddToOptionsView(list: tempArrayOfRestaurants)
                
                // giving feedback to the user //
                self.delegate?.removeStatus(status: "Load Complete!")
            }
        // if the placesArray doesnt exist, send back an empty array //
        }else{
            OptionsSingleton.sharedInstance.listOfPrefferedPlacesAddToOptionsView(list: [])
        }
    }
    
    
    func returnArrayOfPlaces() ->[SavePlacesObject]{
        if let existingData = UserDefaults.standard.object(forKey: "placesArray") as? NSData{
            if let placesArray = NSKeyedUnarchiver.unarchiveObject(with: existingData as Data) as? [SavePlacesObject]{
                
                tempArrayOfRestaurants = placesArray
                
                let userLocation = OptionsSingleton.sharedInstance.getDefaultLocation()
                
                // adjusting the distance in miles //
                for items in tempArrayOfRestaurants{
                    let distanceFromUser = items.location?.distance(from: userLocation)
                    let distanceInMiles = Int(distanceFromUser! / 1609)
                    items.distanceFromUser = distanceInMiles
                }
                return tempArrayOfRestaurants
            }
        }
        return []
    }
    
    
}
