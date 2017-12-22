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
    var isSaved:Bool = false
    var isBlocked:Bool = false
    
    var coder:NSCoder?
    
    override init() {
        super.init()
    }
    
    
    init(_name:String, _location:CLLocation, _open:Bool, _price:Int, _rating:Double, _distanceFromUser:Int, _isSaved:Bool, _isBlocked:Bool){
        
        self.name = _name
        self.location = _location
        self.open = _open
        self.price = _price
        self.rating = _rating
        self.distanceFromUser = _distanceFromUser
        self.isSaved = _isSaved
        self.isBlocked = _isBlocked
    }
    
    func setIsSaved(save:Bool){
        isSaved = save
    }
    
    func setIsBlocked(blocked:Bool){
        isBlocked = blocked
    }
    
    
    
    func encode(with aCoder: NSCoder) {
        
        
        aCoder.encode(name, forKey: "name")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(open, forKey: "open")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(distanceFromUser, forKey: "distance")
        aCoder.encode(isSaved, forKey: "isSaved")
        aCoder.encode(isBlocked, forKey: "isBlocked")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = (aDecoder.decodeObject(forKey: "name") as! String)
        self.location = (aDecoder.decodeObject(forKey: "location") as! CLLocation)
        self.open = (aDecoder.decodeObject(forKey: "open") as! Bool)
        self.price = (aDecoder.decodeObject(forKey: "price") as! Int)
        self.rating = (aDecoder.decodeObject(forKey: "rating") as! Double)
        self.distanceFromUser = (aDecoder.decodeObject(forKey: "distance") as! Int)
        self.isSaved = Bool(aDecoder.decodeBool(forKey: "isSaved"))
        self.isBlocked = Bool(aDecoder.decodeBool(forKey: "isBlocked"))
    }
}
