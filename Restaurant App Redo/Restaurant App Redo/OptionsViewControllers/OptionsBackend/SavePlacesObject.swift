//
//  SavePlacesObject.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 11/5/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit
import MapKit

class SavePlacesObject: NSObject, NSCoding {
    
    
    var name:String?
    var location:CLLocation?
    var open:Bool?
    var price:Int?
    var rating:Double?
    var distanceFromUser:Int?
    var annotationColor:Bool?
    var keywordsString:String?
    
    override init() {
        super.init()
    }
    
    
    init(_name:String, _location:CLLocation, _open:Bool, _price:Int, _rating:Double, _distanceFromUser:Int){
        
        self.name = _name
        self.location = _location
        self.open = _open
        self.price = _price
        self.rating = _rating
        self.distanceFromUser = _distanceFromUser
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(open, forKey: "open")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(distanceFromUser, forKey: "distance")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = (aDecoder.decodeObject(forKey: "name") as! String)
        self.location = (aDecoder.decodeObject(forKey: "location") as! CLLocation)
        self.open = (aDecoder.decodeObject(forKey: "open") as! Bool)
        self.price = (aDecoder.decodeObject(forKey: "price") as! Int)
        self.rating = (aDecoder.decodeObject(forKey: "rating") as! Double)
        self.distanceFromUser = (aDecoder.decodeObject(forKey: "distance") as! Int)
    }
}
