//
//  LocationServices.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/17/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation

@objc protocol ReturnLocationDelegate{
    func returnLocation(location:CLLocation)
}

class LocationServices: NSObject, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager?
    var hasTriggered:Bool = false
    
    var delegate:ReturnLocationDelegate?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 100
        locationManager?.requestWhenInUseAuthorization()
        
    }
    
    func startLocationServices(){
        hasTriggered = false
        locationManager?.startUpdatingLocation()
    }
    
    func stopLocationServices(){
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        if(hasTriggered == false){
            if(lastLocation != nil){
                
                if(lastLocation!.horizontalAccuracy > 100){
                    return
                }else{
                    hasTriggered = true
                    
                    self.delegate?.returnLocation(location: lastLocation!)
                    self.stopLocationServices()
                }
            }
        }
    }


}
