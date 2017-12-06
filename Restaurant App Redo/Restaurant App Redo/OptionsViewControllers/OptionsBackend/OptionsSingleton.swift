//
//  OptionsSingleton.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/21/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnOptionsUpdatedDelegate{
    func returnOptionsDidChange()
}

// setting up an options object //
// holds the users options //
// there can be only one!!!! //
class OptionsSingleton: NSObject {

    static let sharedInstance = OptionsSingleton()
    var delegate:ReturnOptionsUpdatedDelegate?
    
    var tempArrayOfplaces:[SavePlacesObject] = []
    var tempArrayOfNoGoPlaces:[SavePlacesObject] = []
    
    func deleteAllOptions(){
        UserDefaults.standard.removeObject(forKey: "DistanceUserDefault")
        UserDefaults.standard.removeObject(forKey: "RatingUserDefault")
        UserDefaults.standard.removeObject(forKey: "PriceUserDefault")
        UserDefaults.standard.removeObject(forKey: "TimeOfDayUserDefault")
        self.delegate?.returnOptionsDidChange()
    }
    
    // distance //
    func setDistance(distance:Int){
        UserDefaults.standard.set(distance, forKey: "DistanceUserDefault")
        self.delegate?.returnOptionsDidChange()
    }
    
    func getDistance() ->Int{
        if(UserDefaults.standard.object(forKey: "DistanceUserDefault") != nil){
            let distance = UserDefaults.standard.object(forKey: "DistanceUserDefault")
            return distance as! Int
        }else{
            return 5
        }
    }
    
    func removeDistance(){
        UserDefaults.standard.removeObject(forKey: "DistanceUserDefault")
    }
    // ... //
    
    // rating //
    func setRating(rating:Int){
        
        UserDefaults.standard.set(rating, forKey: "RatingUserDefault")
        self.delegate?.returnOptionsDidChange()
    }
    
    func getRating() ->Int{
        if(UserDefaults.standard.object(forKey: "RatingUserDefault") != nil){
            let rating = UserDefaults.standard.object(forKey: "RatingUserDefault")
            return rating as! Int
        }else{
            return 0
        }
    }
    
    func removeRating(){
        UserDefaults.standard.removeObject(forKey: "RatingUserDefault")
    }
    // ... //
    
    // price //
    func setPrice(price:Int){
        
        UserDefaults.standard.set(price, forKey: "PriceUserDefault")
        self.delegate?.returnOptionsDidChange()
    }
    
    func getPrice() ->Int{
        if(UserDefaults.standard.object(forKey: "PriceUserDefault") != nil){
            let price = UserDefaults.standard.object(forKey: "PriceUserDefault")
            return price as! Int
        }else{
            return 0
        }
    }
    
    func removePrice(){
        UserDefaults.standard.removeObject(forKey: "PriceUserDefault")
    }
    // ... //
    
    
    // keywords //
    func setKeyWords(keywords:[String]){
        UserDefaults.standard.set(keywords, forKey: "keywords")
        self.delegate?.returnOptionsDidChange()
    }
    
    func getKeywords() ->[String]{
        if(UserDefaults.standard.object(forKey: "keywords") != nil){
            let keywords = UserDefaults.standard.object(forKey: "keywords")
            return keywords as! [String]
        }else{
            return []
        }
    }
    
    func removeKeywords(){
        UserDefaults.standard.removeObject(forKey: "keywords")
    }
    
    
    
    
    func setSavedListToggleOnAndOff(toggleSavedList:Bool){
        UserDefaults.standard.set(toggleSavedList, forKey: "savedListOnOff")
        self.delegate?.returnOptionsDidChange()
    }
    
    func getSavedListToggleOnAndOff() ->Bool{
        if(UserDefaults.standard.object(forKey: "savedListOnOff") != nil){
            let onOff = UserDefaults.standard.object(forKey: "savedListOnOff")
            return onOff as! Bool
        }else{
            return false
        }
    }
    
    
    func setBlockedListToggleOnAndOff(toggleBlockedList:Bool){
        UserDefaults.standard.set(toggleBlockedList, forKey: "blockedListOnOff")
        self.delegate?.returnOptionsDidChange()
    }
    
    func getBlockedListToggleOnAndOff() ->Bool{
        if(UserDefaults.standard.object(forKey: "blockedListOnOff") != nil){
            let onOff = UserDefaults.standard.object(forKey: "blockedListOnOff")
            return onOff as! Bool
        }else{
            return false
        }
    }
    
    
    
    
    func existsInSavedList(item:SavePlacesObject) ->Bool{
        var tempExists:Bool = false
        if let existingDataPreferred = UserDefaults.standard.object(forKey: "placesArray") as? NSData{
            if let placesArrayPreferred = NSKeyedUnarchiver.unarchiveObject(with: existingDataPreferred as Data) as? [SavePlacesObject]{
                for items in placesArrayPreferred{
                    if(items.name! == item.name ){
                        tempExists = true
                    }
                }
            }
        }
        return tempExists
    }
    
    
    func existsInNoGo(item:SavePlacesObject) ->Bool{
        var tempExists:Bool = false
        if let existingDataNoGo = UserDefaults.standard.object(forKey: "noGoPlacesArray") as? NSData{
            if let placesArrayNoGo = NSKeyedUnarchiver.unarchiveObject(with: existingDataNoGo as Data) as? [SavePlacesObject]{
                for items in placesArrayNoGo{
                    if(items.name! == item.name){
                        tempExists = true
                    }
                }
            }
        }
        return tempExists
    }
    
    
    
    // ---- need to come back to this guy ---- //
    func updateDidChangeOptions(){
        self.delegate?.returnOptionsDidChange()
    }
    
    
    
    // Saving the list of places to preferred list //
    func listOfPrefferedPlacesAddToOptionsView(list:[SavePlacesObject]){
        tempArrayOfplaces = list
        //self.delegate?.returnOptionsDidChange()
    }
    
    func listOfNoGoPlacesAddToOptionsView(list:[SavePlacesObject]){
        tempArrayOfNoGoPlaces = list
        //self.delegate?.returnOptionsDidChange()
    }
  
}
