//
//  RestaurantInfo.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/17/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation

class RestaurantInfo: NSObject{
    
    var name:String?
    var location:CLLocation?
    var open:Bool?
    var price:Int?
    var rating:Double?
    
    var distanceFromUser:Int?
}
