//
//  GetNewDefaultLocation.swift
//  Restaurant App Redo 3
//
//  Created by Cory Green on 11/25/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//



// this will take in a string address and bring back a CLLocation //
import UIKit
import CoreLocation

@objc protocol ReturnLiteralStringSearch{
    func returnLocationData(location:[DefaultLocationObject])
    func working(yesNo:Bool)
}

class GetNewDefaultLocation: NSObject {
    
    var key:String = "AIzaSyDhaomO-UDL3dm0RF_byquX6-2mjvyHGuM"
    
    var _location:String = ""
    var delegate:ReturnLiteralStringSearch?
    
    var dataTask: URLSessionDataTask?
    var arrayOfLocations:[DefaultLocationObject] = []
    
    
    // init by string //
    init(locationString:String) {
        super.init()
        _location = locationString
        
    }

    
    // performs the search based on a location //
    // this is used for searching for a new default location //
    func performSearchWithString(){
        let urlString:String = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(_location)&key=\(key)"
        var url:URL?
        if let tempUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
            url = URL(string: tempUrl)
            
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
                        self.parseData(data: data)
                        self.delegate?.working(yesNo: false)
                    }
                }
            })
            dataTask?.resume()
        }
    }

    
    func parseData(data:Data){
        do{
            
            arrayOfLocations.removeAll()
            let jsonData = try JSONSerialization.jsonObject(with: data) as? [String:AnyObject]
            //print(jsonData)
            
            guard let results = jsonData!["results"] as? [[String:AnyObject]] else{
                return
            }
            
            for items in results{
                
                let newDefaultLocation:DefaultLocationObject = DefaultLocationObject()
                
                // getting the location as CLLocation object //
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
                newDefaultLocation.location = restLocation
                
                
                for upperLevel in items as [String:AnyObject]{
                    if(upperLevel.key == "formatted_address"){
                        newDefaultLocation.address = (upperLevel.value as! String)
                    }
                    if(upperLevel.key == "name"){
                        newDefaultLocation.name = (upperLevel.value as! String)
                    }
                }
                
                //self.delegate?.returnLocationData(location: newDefaultLocation)
                self.arrayOfLocations.append(newDefaultLocation)
                
            }
            self.delegate?.returnLocationData(location: arrayOfLocations)
        }catch let jsonError{
                print(jsonError)
        }
        
    }
    
}
