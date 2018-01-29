//
//  GatheringPlacesNear.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 1/1/18.
//  Copyright © 2018 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation

@objc protocol ReturnRestaurauntInfoAndLocation{
    func returnRestaurantInfo(info:SavePlacesObject)
    func working(yesNo:Bool)
    func reachedTheEndOfSet()
    func reachedBeginningOfSet()
}

class GatheringPlacesNear: NSObject {
    
    var _locationOfUser:CLLocation?
    
    var delegate:ReturnRestaurauntInfoAndLocation?
    
    var key:String = "AIzaSyDhaomO-UDL3dm0RF_byquX6-2mjvyHGuM"
    var nextPageToken:String = ""
    var type:String = "restaurant"
    var keyword:String = "pizza"
    var _keywordString:String = ""
    
    var dataTask: URLSessionDataTask?
    
    var arrayOfRestaurants:[SavePlacesObject] = []
    
    var arrayOfRandomNumbersGenerated:[Int] = []
    
    var numberOn:Int?
    var arraysOfNextPageTokens:[String] = []
    
    override init() {
        super.init()
    }
    
    
    func search(location:CLLocation){
        _locationOfUser = location
        
        // gets the miles * meters //
        let _radius = OptionsSingleton.sharedInstance.getDistance() * 1609
        
        // gets the max pricing //
        let _pricing = OptionsSingleton.sharedInstance.getPrice()
        
        var url:URL?
        var urlString:String?
        
        _keywordString = self.manageKeywords()
        if(_keywordString == ""){
            _keywordString = "cruise"
        }
        
        if(nextPageToken == ""){
            
            urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=\(_radius)&type=\(type)&keyword=\(_keywordString)&minprice=0&maxprice=\(_pricing)&key=\(key)"
            
        }else{
            urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(nextPageToken)&location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=\(_radius)&type=\(type)&keyword=\(_keywordString)&minprice=0&maxprice=\(_pricing)&key=\(key)"
        }
        
        if let tempUrl = urlString?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
            url = URL(string: tempUrl)
            
            var dataTask:URLSessionDataTask?
            let defaultSession = URLSession(configuration: .default)
            var errorMessage = ""
            
            self.delegate?.working(yesNo: true)
            dataTask?.cancel()
            
            dataTask = defaultSession.dataTask(with: url!, completionHandler: { (data, response, error) in
                defer  {self.dataTask = nil}
                if(data != nil){
                    
                    if let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200{
                        self.parseResults(data: data)
                        self.delegate?.working(yesNo: false)
                    }
                    
                }
            })
            dataTask?.resume()
        }
    }
    
    // parsing the results //
    func parseResults(data:Data){
        do{
            let jsonData = try JSONSerialization.jsonObject(with: data) as? [String:AnyObject]

            
            
            
            // getting the next page token //
            if let nextPageTokenInfo = jsonData!["next_page_token"]{
                nextPageToken = (nextPageTokenInfo as! String)
            }
            
            
            
            // getting the main results //
            guard let results = jsonData!["results"] as? [[String:AnyObject]] else{
                return
            }
            
            
            self.arrayOfRestaurants.removeAll()
            self.arrayOfRandomNumbersGenerated.removeAll()
            self.numberOn = nil
            
            for items in results{
                
                // instantiating a new save places object //
                let newRestaurantInfo:SavePlacesObject = SavePlacesObject()
                
                // getting location info //
                guard let geometryLevel = items["geometry"] as? [String:AnyObject] else{
                    return
                }
                
                guard let _location = geometryLevel["location"] as? [String:AnyObject] else{
                    return
                }
                
                var lat:CLLocationDegrees?
                var long:CLLocationDegrees?
                
                var restLocation:CLLocation?
                
                // getting the location //
                for (index,location) in _location.enumerated(){
                    if(index == 0){
                        
                        lat = location.value as? CLLocationDegrees
                    }else if(index == 1){
                        
                        long = location.value as? CLLocationDegrees
                    }
                }
                
                restLocation = CLLocation(latitude: lat!, longitude: long!)
                newRestaurantInfo.location = restLocation
                
                // rating, name, and price level //
                for ratingUpperLevel in items as [String:AnyObject]{
                    if(ratingUpperLevel.key == "rating"){
                        newRestaurantInfo.rating = (ratingUpperLevel.value as! Double)
                    }
                    if(ratingUpperLevel.key == "name"){
                        newRestaurantInfo.name = (ratingUpperLevel.value as! String)
                    }
                    
                    if(ratingUpperLevel.key == "price_level"){
                        newRestaurantInfo.price = (ratingUpperLevel.value as! Int)
                    }
                }
                
                // is open //
                if let openingHoursUpperLevel = items["opening_hours"] as? [String:AnyObject]{
                    
                    if(openingHoursUpperLevel["open_now"] != nil){
                        
                        newRestaurantInfo.open = (openingHoursUpperLevel["open_now"]! as! Bool)
                    }else{
                        newRestaurantInfo.open = false
                    }
                    
                }else{
                    newRestaurantInfo.open = false
                }
                
                // adding to the array of restaurant info //
                if(self.filterResultsBasedOnOtherCriteria(place: newRestaurantInfo) == true){
                
                
                    // doing some basic filtering of the results //
                    // need to filter by rating also //
                
                    let noGoSavingObject:NoGoSaving = NoGoSaving()
                    let listOfBlockedPlaces = noGoSavingObject.returnArrayOfPlaces()
                
                    var contains = false
                    for items in listOfBlockedPlaces{
                        if(items.name == newRestaurantInfo.name){
                            contains = true
                        }
                    }
                
                
                    // setting the distance from the user //
                    if(contains == false){
                        
                        let userLocation = OptionsSingleton.sharedInstance.getDefaultLocation()
                        
                        let distanceFromUser = newRestaurantInfo.location?.distance(from: userLocation)
                        let distanceFromUserInMiles = Int(distanceFromUser! / 1609)
                        newRestaurantInfo.distanceFromUser = distanceFromUserInMiles
                        newRestaurantInfo.annotationColor = true
                        arrayOfRestaurants.append(newRestaurantInfo)
                    }
                }
            }
            
            
            
            
            // getting the combined restaurant list with the saved places list //
            self.returnAllRestaurauntsIncludingSavedPlaces()
            
            // assigning random numbers to the restaurants for //
            // getting the next and previous places //
            self.assigningRandomNumbersToRestaurants()
            

        }catch let error{
            print(error)
        }
    }
    
    // need to make sure the main view controller knows to reload data //
    func manageKeywords() ->String{
        let keywordArray = OptionsSingleton.sharedInstance.getKeywords()
        var keywordString = ""
        for (index, items) in keywordArray.enumerated(){
            if(index != keywordArray.count - 1){
                keywordString += "\(items)+"
            }else{
                keywordString += "\(items)"
            }
        }
        return keywordString
    }
    
    
    // returning all restaurants including those found in your saved list //
    func returnAllRestaurauntsIncludingSavedPlaces(){
    
        let savedPlacesObject:PreferredNoGoSaving = PreferredNoGoSaving()
        var savedPlacesArray = savedPlacesObject.returnArrayOfPlaces()

        
        // adding the saved places array to the beginning of the array of restaurants //
        // gotta go through the self.arrayOfRestaurants to see if there is //
        // duplicates with savedPlacesArray //
        savedPlacesArray += self.arrayOfRestaurants
        self.arrayOfRestaurants = savedPlacesArray
        
        OptionsSingleton.sharedInstance.loadPlaces(places: self.arrayOfRestaurants)

    }
    
    
    
    func assigningRandomNumbersToRestaurants(){
        for _ in self.arrayOfRestaurants{
            if(self.arrayOfRandomNumbersGenerated.count != self.arrayOfRestaurants.count){
                var randomInitialNumber:Int = Int(arc4random_uniform(UInt32(self.arrayOfRestaurants.count) + 0))
                while((self.arrayOfRandomNumbersGenerated.contains(randomInitialNumber))){
                    randomInitialNumber = Int(arc4random_uniform(UInt32(self.arrayOfRestaurants.count) + 0))
                }
                self.arrayOfRandomNumbersGenerated.append(randomInitialNumber)
            }
        }
    }
    
    
    
    func gettingNextRestaurant(){
        if(self.arrayOfRestaurants.count != 0){
            if(numberOn != self.arrayOfRestaurants.count - 1){
                if(numberOn == nil){
                    numberOn = 0
                    self.delegate?.returnRestaurantInfo(info: self.arrayOfRestaurants[self.arrayOfRandomNumbersGenerated[numberOn!]])
                }else{
                    numberOn = numberOn! + 1
                    self.delegate?.returnRestaurantInfo(info: self.arrayOfRestaurants[self.arrayOfRandomNumbersGenerated[numberOn!]])
                }
            }else{
                self.delegate?.reachedTheEndOfSet()
            }
        }
    }
    
    
    func gettingPreviousRestaurant(){
        if(self.arrayOfRestaurants.count != 0){
            if(numberOn != nil){
                if(!(numberOn! <= 0)){
                    numberOn! = numberOn! - 1
                    self.delegate?.returnRestaurantInfo(info: self.arrayOfRestaurants[self.arrayOfRandomNumbersGenerated[numberOn!]])
                }else{
                    numberOn = nil
                    // tell the view controller that its reached the beginning and needs to start over //
                    // at the beginning
                    self.delegate?.reachedBeginningOfSet()
                
                }
            }
        }
    }
    
    func eraseAllInfo(){
        nextPageToken = ""
        self.arrayOfRestaurants.removeAll()
        self.arrayOfRandomNumbersGenerated.removeAll()
    }
    
    // will be letting is open slide through.
    // if a place isnt open, I want the annotation to be greyed out
    func filterResultsBasedOnOtherCriteria(place:SavePlacesObject) ->Bool{
        if(place.rating != nil){
            
            if(Int(place.rating!) >= OptionsSingleton.sharedInstance.getRating() + 1){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
}
