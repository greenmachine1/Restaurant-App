//
//  ViewController.swift
//  Restaurant App Redo 3
//
//  Created by Cory Green on 11/24/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, ReturnLocationDelegate, ReturnLiteralStringSearch, ReturnSurroundingRestaurantDelegate {

    var previousButton:UIButton?
    var nextButton:UIButton?
    
    // location stuff //
    var _location:CLLocation?
    var _region:MKCoordinateRegion?
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var mainTextField: UITextField!
    @IBOutlet weak var searchOrRecenterButton: UIButton!
    
    var newNavigationController:NavigationController?
    
    var gatheringNewPlaces:GetSurroundingRestaurantPlaces?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTextField.delegate = self
        
        self.gatheringNewPlaces = GetSurroundingRestaurantPlaces()
        
        // adding a tap gesture to dismiss the keyboard if the user taps on the screen //
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
        // setting up the nav bar buttons //
        let optionsButton:UIBarButtonItem = UIBarButtonItem(title: "Options", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.optionsSelected))
        let listButton:UIBarButtonItem = UIBarButtonItem(title: "List", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.listSelected))
        self.navigationItem.setRightBarButtonItems([ optionsButton,listButton], animated: true)
        
        // When the app doesnt have anything loaded up //
        // only the next button will appear usable //
        self.showOnlyNextButton()
        
        // setting the default look for the search button //
        self.setDefaultAppearanceForSearchButton()
        
        // this will always be the same //
        self.searchOrRecenterButton.layer.cornerRadius = self.searchOrRecenterButton.frame.size.width / 2
        self.searchOrRecenterButton.clipsToBounds = true
        self.searchOrRecenterButton.addTarget(self, action: #selector(self.currentLocationOrSearchButtonClick), for: UIControlEvents.touchUpInside)
        
        
        // setting the default appearance for the main text field //
        // this wont change so ill be hard coding it here //
        self.mainTextField.layer.cornerRadius = self.mainTextField.frame.size.height / 2
        self.mainTextField.clipsToBounds = true
        self.mainTextField.addTarget(self, action: #selector(modifiedTextField(_:)), for: UIControlEvents.allEditingEvents)
        
        
        // starting up locationServices //
        self.startLocationServices()
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    // do something if the text field gets modified //
    @objc func modifiedTextField(_ textField:UITextField){
        if(textField.text?.count == 0){
            self.setDefaultAppearanceForSearchButton()
        }else{
            self.setSearchAppearanceForSearchButton()
        }
    }
    
    
    func setDefaultAppearanceForSearchButton(){
        self.searchOrRecenterButton.backgroundColor = Colors.sharedInstance.lightBlue
        self.searchOrRecenterButton.setTitle("><", for: UIControlState.normal)
        self.searchOrRecenterButton.setTitleColor(UIColor.white, for: UIControlState.normal)
   
    }
    
    func setSearchAppearanceForSearchButton(){
        self.searchOrRecenterButton.backgroundColor = Colors.sharedInstance.lightOrange
        self.searchOrRecenterButton.setTitle("Go", for: UIControlState.normal)
        self.searchOrRecenterButton.setTitleColor(UIColor.white, for: UIControlState.normal)
  
    }
    
    @objc func currentLocationOrSearchButtonClick(sender:UIButton){
        if(sender.titleLabel?.text == "Go"){
            // perform a search for the address the user has entered //
            self.performNewSearchForDefaultLocation()
        }else{
            
            // recenter the user //
            self.startLocationServices()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.performNewSearchForDefaultLocation()
        
        return true
    }
    
    func performNewSearchForDefaultLocation(){
       
        let newSearch:GetNewDefaultLocation = GetNewDefaultLocation(locationString: self.mainTextField.text!)
        newSearch.delegate = self
        newSearch.performSearchWithString()
    }
    
    
    
    
    
    
    
    
    
    
    // ---- nav bar button stuff ---- //
    @objc func optionsSelected(){
        
    }
    
    @objc func listSelected(){
        
    }
    
    
    
    
    
    
    
    
    
    
    
    // ---- bottom button stuff ---- //
    
    // this is what the app starts out with upon loading //
    func showOnlyNextButton(){
        UIView.animate(withDuration: 0.2, animations: {
            self.nextButton = UIButton(frame: CGRect(x: self.mainMapView.frame.origin.x, y: self.view.frame.size.height - 70, width: self.view.frame.size.width, height: 70))
            self.nextButton?.setTitle("Next", for: UIControlState.normal)
            self.nextButton?.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.nextButton?.backgroundColor = Colors.sharedInstance.lightGreen
            self.nextButton?.addTarget(self, action: #selector(self.nextButtonClicked), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.nextButton!)
            
            self.previousButton = UIButton(frame: CGRect(x: self.mainMapView.frame.origin.x, y: self.view.frame.size.height - 70, width: 0, height: 70))
            
            self.previousButton?.setTitle("Previous", for: UIControlState.normal)
            self.previousButton?.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.previousButton?.backgroundColor = Colors.sharedInstance.lightBlue
            self.previousButton?.addTarget(self, action: #selector(self.previousButtonClicked), for: UIControlEvents.touchUpInside)
            
            self.view.addSubview(self.previousButton!)
        }) { (complete) in
            
        }
        
    }
    
    
    
    func showBothPreviousAndNextButtons(){
        UIView.animate(withDuration: 0.2, animations: {
            self.previousButton?.frame = CGRect(x: self.mainMapView.frame.origin.x, y: self.view.frame.size.height - 70, width: self.view.frame.size.width / 2, height: 70)
            self.nextButton?.frame = CGRect(x: self.mainMapView.frame.origin.x + (self.previousButton?.frame.size.width)!, y: self.view.frame.size.height - 70, width: self.view.frame.size.width / 2, height: 70)
            
        }) { (complete) in
            
        }
    }
    
    func showOnlyPreviousButtons(){
        UIView.animate(withDuration: 0.2, animations: {
            self.previousButton?.frame = CGRect(x: self.mainMapView.frame.origin.x, y: self.view.frame.size.height - 70, width: self.view.frame.size.width, height: 70)
            self.nextButton?.frame = CGRect(x: self.mainMapView.frame.origin.x + (self.previousButton?.frame.size.width)!, y: self.view.frame.size.height - 70, width: 0, height: 70)
        }) { (complete) in
            
        }
    }
    
    @objc func nextButtonClicked(){
        if(self._location != nil){
            
            if(self.gatheringNewPlaces != nil){
                self.gatheringNewPlaces?.gettingRandomRestaurant()
                self.showBothPreviousAndNextButtons()
            }
        }
    }
    
    @objc func previousButtonClicked(){
        self.showOnlyPreviousButtons()
    }

    
    
    
    
    // ---- returning restaurant info stuff ---- //
    func returnRestaurantInfoArray(info: [RestaurantObject]) {
        print(info.count)
    }
    
    // letting the rest of the app that the end of set has been reached //
    // and we should get a new set //
    func reachedTheEndOfSet() {
        
    }
    
    // returns a single random place
    func returnRestaurantInfo(info: RestaurantObject) {
        self.showLocationOfRestaurant(info: info)
    }
    
    func showLocationOfRestaurant(info:RestaurantObject){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: info.location!.coordinate.latitude, longitude: info.location!.coordinate.longitude)
            self._region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
            let annotation:MKPointAnnotation = MKPointAnnotation()
            let _coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (info.location?.coordinate.latitude)!, longitude: (info.location?.coordinate.longitude)!)
            annotation.coordinate = _coordinate
            annotation.title = info.name!
            self.mainMapView.setRegion(self._region!, animated: true)
            self.mainMapView.addAnnotation(annotation)
        }
    }
    
    
    
    
    // ---- location stuff ---- //
    // startup location services
    func startLocationServices(){
        newNavigationController = NavigationController()
        newNavigationController!.delegate = self
        newNavigationController!.startLocationServices()
        
        self.mainMapView.showsUserLocation = true
        self.mainMapView.delegate = self
    }
    
    // this is from looking up the users current location //
    func returnLocation(location: CLLocation) {
        self._location = location
        self.removeExistingAnnotations()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self._region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
            self.mainMapView.setRegion(self._region!, animated: true)
            self.gatheringNewPlaces!.delegate = self
            self.gatheringNewPlaces!.newSearch(location: self._location!)
        }
    }
    
    
    // this is from setting a new default location //
    func returnLocationData(location: [DefaultLocationObject]) {
        self.showAllPossibleLocations(locations: location)
    }
    
    func working(yesNo: Bool) {
        print(yesNo)
    }
    
    // // shows all posible default locations //
    func showAllPossibleLocations(locations:[DefaultLocationObject]){
        self.removeExistingAnnotations()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
        var tempAnnotations:[MKPointAnnotation] = []
            for location in locations{
                let annotation:MKPointAnnotation = MKPointAnnotation()
                let _coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (location.location?.coordinate.latitude)!, longitude: (location.location?.coordinate.longitude)!)
                annotation.coordinate = _coordinate
                annotation.title = location.name
                tempAnnotations.append(annotation)
            }
            self.mainMapView.showAnnotations(tempAnnotations, animated: true)
        }
    }
    
    // selecting one annotation will make that the new default location //
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let alert = UIAlertController(title: "Do you wish to make this location your new default location?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (action) in
            let location:CLLocation = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
            self._location = location
            
            // gathering new places based on the new default location //
            self.gatheringNewPlaces = GetSurroundingRestaurantPlaces()
            self.gatheringNewPlaces!.delegate = self
            self.gatheringNewPlaces!.newSearch(location: self._location!)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // removing existing annotations //
    func removeExistingAnnotations(){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            for views in self.mainMapView.annotations{
                self.mainMapView.removeAnnotation(views)
            }
        }
    }
   
}

