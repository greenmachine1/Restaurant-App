//
//  GetSurroundingRestaurantPlaces.swift
//  Restaurant App Redo 3
//
//  Created by Cory Green on 11/26/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit
import MapKit

@objc protocol ReturnSurroundingRestaurantDelegate{
    func returnRestaurantInfoArray(info:[RestaurantObject])
    func returnRestaurantInfo(info:RestaurantObject)
    func reachedTheEndOfSet()
}

class GetSurroundingRestaurantPlaces: NSObject {
    
    var key:String = "AIzaSyDhaomO-UDL3dm0RF_byquX6-2mjvyHGuM"
    var type:String = "restaurant"
    var keyword:String = "Chinese"
    var delegate:ReturnSurroundingRestaurantDelegate?
    
    var dataTask:URLSessionDataTask?
    
    var _locationOfUser:CLLocation?
    
    var nextPageToken:String = ""
    
    var arrayOfRestaurants:[RestaurantObject] = []
    
    var arrayOfRandomNumbersGenerated:[Int] = []
    
    override init() {
        super.init()
    }
    
    func newSearch(location:CLLocation){
        _locationOfUser = location
        
        print(location)
        var url:URL?
        
        let tempUrlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=\(10000)&type=\(type)&keyword=\(keyword)&key=\(key)"
        
        if let tempUrl = tempUrlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
            url = URL(string: tempUrl)
            
            
            let defaultSession = URLSession(configuration: .default)
            var errorMessage = ""
            
            dataTask = defaultSession.dataTask(with: url!, completionHandler: { (data, response, error) in
                defer  {self.dataTask = nil}
                if(data != nil){
                    
                    if let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200{
                        
                            self.parseResults(data: data)
                            //self.delegate?.working(yesNo: false)
                    }
                }
            })
            dataTask?.resume()
        }
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
            print(results)
            
            for items in results{
                print(items)
                let newRestaurantInfo:RestaurantObject = RestaurantObject()
                
                
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
                self.arrayOfRestaurants.append(newRestaurantInfo)
                
                
                
            }
            self.delegate?.returnRestaurantInfoArray(info: arrayOfRestaurants)
            
        }catch let jsonError{
            print(jsonError)
        }
    }
    
    func gettingRandomRestaurant(){
        
        if(self.arrayOfRestaurants.count != 0){
            
            if(self.arrayOfRandomNumbersGenerated.count != self.arrayOfRestaurants.count){
                
                var randomInitialNumber:Int = Int(arc4random_uniform(UInt32(self.arrayOfRestaurants.count) + 0))
                while((self.arrayOfRandomNumbersGenerated.contains(randomInitialNumber))){
                    randomInitialNumber = Int(arc4random_uniform(UInt32(self.arrayOfRestaurants.count) + 0))
                }
                self.arrayOfRandomNumbersGenerated.append(randomInitialNumber)
                self.delegate?.returnRestaurantInfo(info: self.arrayOfRestaurants[randomInitialNumber])
                
            }else{
                
                self.arrayOfRandomNumbersGenerated.removeAll()
                self.arrayOfRestaurants.removeAll()
                self.delegate?.reachedTheEndOfSet()
            }
        }
    }
        
    
}
