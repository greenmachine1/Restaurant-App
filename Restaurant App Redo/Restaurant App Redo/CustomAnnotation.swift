//
//  CustomAnnotation.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/22/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

// individual annotations //

import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var title:String?
    var rating:Int?
    var distance:Int?
    var price:Int?
    var isOpen:Bool?
    var coordinate:CLLocationCoordinate2D

    init(_title:String, _rating:Int, _distance:Int, _price:Int, _isOpen:Bool, _coordinate:CLLocationCoordinate2D) {
        
        self.coordinate = _coordinate
        self.title = _title
        self.rating = _rating
        self.distance = _distance
        self.price = _price
        self.isOpen = _isOpen

        super.init()
    }
    
    
}
