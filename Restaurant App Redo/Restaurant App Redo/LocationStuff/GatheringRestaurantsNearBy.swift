//
//  GatheringRestaurantsNearBy.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/17/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation

@objc protocol ReturnRestaurauntInfoAndLocationDelegate{
    func returnRestaurantInfo(info:SavePlacesObject)
    func working(yesNo:Bool)
    func reachedTheEndOfSet()
}


class GatheringRestaurantsNearBy: NSObject{
    
    var delegate:ReturnRestaurauntInfoAndLocationDelegate?
    var key:String = "AIzaSyDhaomO-UDL3dm0RF_byquX6-2mjvyHGuM"
    var type:String = "restaurant"
    var keyword:String = "pizza"
    var _keywordString:String = ""
    var nextPageToken:String = ""
    
    var _locationOfUser:CLLocation?
    
    var dataTask: URLSessionDataTask?

    var arrayOfRestaurants:[SavePlacesObject] = []
    var finalArrayOfRestaurants:[SavePlacesObject] = []
    
    var arrayOfRandomNumbersGenerated:[Int] = []
    
    override init() {
        super.init()
    }
    
    // need to setup a page token to get more than just these results everytime //
    func newSearch(_location:CLLocation){
        
        finalArrayOfRestaurants.removeAll()
        _locationOfUser = _location
        
        // gets the miles * meters //
        let _radius = OptionsSingleton.sharedInstance.getDistance() * 1609
        
        // gets the max pricing //
        let _pricing = OptionsSingleton.sharedInstance.getPrice()
        
        _keywordString = self.manageKeywords()
        if(_keywordString == ""){
            _keywordString = "cruise"
        }
        
        var url:URL?
        var tempUrlString:String?

            if(nextPageToken == ""){

                tempUrlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(_location.coordinate.latitude),\(_location.coordinate.longitude)&radius=\(_radius)&type=\(type)&keyword=\(_keywordString)&minprice=\(_pricing)&key=\(key)"
            
            }else{
                tempUrlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(nextPageToken)&location=\(_location.coordinate.latitude),\(_location.coordinate.longitude)&radius=\(_radius)&type=\(type)&keyword=\(_keywordString)&minprice=\(_pricing)&key=\(key)"
            }
        

            if let tempUrl = tempUrlString?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
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
    
    func eraseAllInfo(){
        nextPageToken = ""
        self.arrayOfRestaurants.removeAll()
        self.arrayOfRandomNumbersGenerated.removeAll()
    }
    
    
    func parseResults(data:Data){
        do{
            let jsonData = try JSONSerialization.jsonObject(with: data) as? [String:AnyObject]

            if let nextPageTokenInfo = jsonData!["next_page_token"]{
                nextPageToken = (nextPageTokenInfo as! String)
            }
            

            guard let results = jsonData!["results"] as? [[String:AnyObject]] else{
                return
            }

            for items in results{

                let newRestaurantInfo:SavePlacesObject = SavePlacesObject()
                
                
                //print("\n\(items)\n")
                
                // getting the location of the restaurant //
                //
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
                //
                // end of getting location //
                
                // rating, name, and price level //
                //
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
                //
                // end of rating //
                
                
                // opening hours //
                //
                
                if let openingHoursUpperLevel = items["opening_hours"] as? [String:AnyObject]{
                    
                    if(openingHoursUpperLevel["open_now"] != nil){
                        
                        newRestaurantInfo.open = (openingHoursUpperLevel["open_now"]! as! Bool)
                    }else{
                        newRestaurantInfo.open = false
                    }

                }else{
                    newRestaurantInfo.open = false
                }

                //
                // end of opening hours

                
                
                
                // adding keywords to the object //

                newRestaurantInfo.keywordsString = _keywordString
                
                
                // adding to the array of restaurant info //
                if(self.filterResultsBasedOnOtherCriteria(place: newRestaurantInfo) == true){

                    let noGoSavingObject:NoGoSaving = NoGoSaving()
                    let listOfBlockedPlaces = noGoSavingObject.returnArrayOfPlaces()
                        
                    var contains = false
                    for items in listOfBlockedPlaces{
                        if(items.name == newRestaurantInfo.name){
                            contains = true
                        }
                    }
                    if(contains == false){
                        if(_locationOfUser != nil){
                                
                            let distanceFromUser = newRestaurantInfo.location?.distance(from: _locationOfUser!)
                            let distanceFromUserInMiles = Int(distanceFromUser! / 1609)
                            newRestaurantInfo.distanceFromUser = distanceFromUserInMiles
                            newRestaurantInfo.annotationColor = true
                            arrayOfRestaurants.append(newRestaurantInfo)
                        }
                    }
                }
            }

            self.returnAllRestaurauntsIncludingSavedPlaces()
            
        }catch let jsonError{
            print(jsonError)
        }
    }
    
    
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
    
    
    
    func insertArrayOfRestaurants(places:[SavePlacesObject]){
        self.arrayOfRestaurants = places
    }
    
    
    
    
    func gettingRandomRestaurant(){
        self.arrayOfRestaurants = OptionsSingleton.sharedInstance.getPlaces()

        if(self.arrayOfRestaurants.count != 0){
            
            if(self.arrayOfRandomNumbersGenerated.count != self.arrayOfRestaurants.count){
                
                var randomInitialNumber:Int = Int(arc4random_uniform(UInt32(self.arrayOfRestaurants.count) + 0))
                while((self.arrayOfRandomNumbersGenerated.contains(randomInitialNumber))){
                    randomInitialNumber = Int(arc4random_uniform(UInt32(self.arrayOfRestaurants.count) + 0))
                }
                self.arrayOfRandomNumbersGenerated.append(randomInitialNumber)
                self.finalArrayOfRestaurants.append(self.arrayOfRestaurants[randomInitialNumber])
                self.delegate?.returnRestaurantInfo(info: self.arrayOfRestaurants[randomInitialNumber])

            }else{
                
                self.arrayOfRandomNumbersGenerated.removeAll()
                self.arrayOfRestaurants.removeAll()
                self.delegate?.reachedTheEndOfSet()
            }
        }
    }
    
    
    func gettingPreviousRestaurant(){
        for items in self.finalArrayOfRestaurants{
            print(items)
        }
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
