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
    var coordinate:CLLocationCoordinate2D

    init(_title:String, _coordinate:CLLocationCoordinate2D) {
        
        self.coordinate = _coordinate
        self.title = _title

        super.init()
    }
    
    
}
