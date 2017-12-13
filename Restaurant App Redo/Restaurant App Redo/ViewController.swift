//
//  ViewController.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/17/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, ReturnLocationDelegate, ReturnRestaurauntInfoAndLocationDelegate, ReturnOptionsUpdatedDelegate, MKMapViewDelegate, ListViewDelegate, ReturnButtonInfoDelegate, ReturnSaveOfPreferredPlaces, ReturnSaveOfNoGoPlaces, ReturnSwipeGestureDelegate{

    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var reCenterButton: UIButton!
    @IBOutlet weak var workingIndicator: UIActivityIndicatorView!
    
    var getLocation:LocationServices?
    var _location:CLLocation?
    var _region:MKCoordinateRegion?
    
    var reachedEndOfSet:Bool?
    var optionsUpdatedBool:Bool = false
    var noResults:Bool = false
    var popUpListViewOpen:Bool = false
    
    var newSearch:GatheringRestaurantsNearBy?
    var allRestaurantInfo:[SavePlacesObject] = []
    var currentRestaurant:SavePlacesObject?
    
    var popUpView:ListView?
    
    var listOfPlaces:UIBarButtonItem?
    
    var annotation:CustomAnnotation?
    
    var dropDownView:DropDownRestaurantView?
    var dropDownInView:Bool = false
    
    // getting the nav bar height //
    var yLocationOfDropDown:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDropDownMenuUponReload), name: .UIApplicationDidBecomeActive, object: nil)
        
        
        
        // Setting the height from the top of the navbar to the beginning of the usable //
        // screen area //
        yLocationOfDropDown = self.view.frame.origin.y +     (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        
        self.reCenterButton.layer.cornerRadius = self.reCenterButton.frame.size.height / 2
        self.reCenterButton.clipsToBounds = true
        
        self.workingIndicator.stopAnimating()
        self.workingIndicator.hidesWhenStopped = true
        
        
        // setting the reached end of set to false //
        reachedEndOfSet = false
        
        
        
        getLocation = LocationServices()
        getLocation!.delegate = self
        getLocation!.startLocationServices()
        
        mainMapView.showsUserLocation = true
        mainMapView.delegate = self
        
        OptionsSingleton.sharedInstance.delegate = self
        
        let optionsButton:UIBarButtonItem = UIBarButtonItem(title: "Options", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.navBarButtonsOnClick))
        optionsButton.tag = 0
        listOfPlaces = UIBarButtonItem(title: "List", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.navBarButtonsOnClick))
        listOfPlaces!.tag = 1
        self.navigationItem.rightBarButtonItems = [optionsButton, listOfPlaces!]
        
        

        // adding in a drop down nav bar box //
        dropDownView = DropDownRestaurantView(frame: CGRect(x: 0, y: -yLocationOfDropDown!, width: self.view.frame.width, height: 100))
        dropDownView?.delegate = self
        dropDownView!.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        dropDownView!.isOpaque = false

        self.view.addSubview(dropDownView!)
        
    }
    
    
    @objc func updateDropDownMenuUponReload(){
        if(dropDownInView == true){
            if(dropDownView != nil){
                // updating the drop down window //
                if(self.currentRestaurant != nil){
                    
                   dropDownView?.updateLabels(main: self.currentRestaurant!.name!, rating: "* \(self.currentRestaurant!.rating!)", price: "$ \(self.currentRestaurant!.price!)", distance: "\(self.currentRestaurant!.distanceFromUser!)mi", open: self.currentRestaurant!.open!)
                }
            }
        }
    }
    
    
    // when the user swipes left or right on the top bar //
    // do stuff //
    func returnSwipeDirection(leftOrRight: Bool) {
        if(leftOrRight == true){
            self.goButtonClickedOrSwipedRight()
        }else{
            print("swiped Left")
        }
    }
    
    
    
    
    
    func returnOptionsDidChange() {
        optionsUpdatedBool = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if(optionsUpdatedBool == true){
            getLocation?.startLocationServices()
            optionsUpdatedBool = false
            if(dropDownInView == true){
                UIView.animate(withDuration: 0.5, animations: {
                    self.dropDownView?.frame = CGRect(x: 0, y: -self.yLocationOfDropDown!, width: self.view.frame.width, height: 100)
                }, completion: { (complete) in
                    self.dropDownInView = false
                })
            }
        }
        
        
        for annotation in self.mainMapView.annotations{
            if(annotation.isKind(of: CustomAnnotation.self)){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Reload"), object: nil, userInfo: ["CurrentPlace":self.currentRestaurant!])
            }
        }
    }

    @objc func navBarButtonsOnClick(sender:UIBarButtonItem){
        if(sender.tag == 0){
            let optionsViewController = self.storyboard?.instantiateViewController(withIdentifier: "Options") as? OptionsViewController
            self.navigationController?.pushViewController(optionsViewController!, animated: true)
        }else{
            self.createListViewPopUp()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // returning the location //
    func returnLocation(location: CLLocation) {
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        _location = location
        _region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mainMapView.setRegion(_region!, animated: true)
        self.mainMapView.showsUserLocation = true
        
        newSearch = GatheringRestaurantsNearBy()
        newSearch!.delegate = self
        
        if(_location != nil){
            newSearch!.newSearch(_location: _location!)
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // returning the place info //
    func returnRestaurantInfo(info: SavePlacesObject) {
        
        currentRestaurant = info
        
        // updating the drop down window //
        dropDownView?.updateLabels(main: info.name!, rating: "* \(info.rating!)", price: "$ \(info.price!)", distance: "\(info.distanceFromUser!)mi", open: info.open!)
        
        if(dropDownInView == false){
            UIView.animate(withDuration: 0.5, animations: {
                self.dropDownView?.frame = CGRect(x: 0, y: self.yLocationOfDropDown!, width: self.view.frame.width, height: 100)
                self.dropDownInView = true
            })
        }
        
        // updating the popUpView //
        if(self.currentRestaurant != nil){
            self.popUpView?.makeItemAppearSelected(item: self.currentRestaurant!)
        }
        
        self.creatingAnnotationWithInfo(info: info)
    }

    
    
    
    // created a seperate function for this so that I can call it from //
    // the return from selecting an item in the list view //
    func creatingAnnotationWithInfo(info:SavePlacesObject){
        mainMapView.removeAnnotations(mainMapView.annotations)
        
        let _coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (info.location?.coordinate.latitude)!, longitude: (info.location?.coordinate.longitude)!)
        _region = MKCoordinateRegionMakeWithDistance(_coordinate, 1000, 1000)
        mainMapView.setRegion(_region!, animated: true)
        
        // making a callout view for the annotation //
        annotation = CustomAnnotation(_title: info.name!, _coordinate: _coordinate)
        
        mainMapView.addAnnotation(annotation!)
    }
    

    
    @IBAction func reCenterOnClick(_ sender: UIButton) {
        newSearch?.eraseAllInfo()
        self.mainMapView.showsUserLocation = true
        mainMapView.removeAnnotations(mainMapView.annotations)
        getLocation!.startLocationServices()
    }
    
    // indicator as to whether or not the network is searching //
    func working(yesNo: Bool) {
        if(yesNo == true){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.workingIndicator.startAnimating()
                self.goButton.isUserInteractionEnabled = false
                self.goButton.setTitle("Loading...", for: UIControlState.normal)
                self.reCenterButton.isUserInteractionEnabled = false
                self.mainMapView.isUserInteractionEnabled = false
                
                self.listOfPlaces?.isEnabled = false
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.workingIndicator.stopAnimating()
                self.goButton.isUserInteractionEnabled = true
                self.goButton.setTitle("Go", for: UIControlState.normal)
                self.reCenterButton.isUserInteractionEnabled = true
                self.mainMapView.isUserInteractionEnabled = true
                
                self.listOfPlaces?.isEnabled = true
                
                if(self.reachedEndOfSet == true){
                    self.newSearch?.gettingRandomRestaurant()
                    self.reachedEndOfSet = false
                }
            }
        }
    }
    
    
    @IBAction func goButtonOnClick(_ sender: UIButton) {
        self.goButtonClickedOrSwipedRight()
    }
    
    
    func goButtonClickedOrSwipedRight(){
        if(noResults == false){
            newSearch?.gettingRandomRestaurant()
            self.mainMapView.showsUserLocation = false
            
            
            
        }else{
            let alert:UIAlertController = UIAlertController(title: "No results Found", message: "Try adjusting your options for better results", preferredStyle: UIAlertControllerStyle.alert)
            let okButton:UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    
    
    // ---- Map View Annotation Stuff ---- //
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = CustomAnnotationCalloutView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        return annotationView
    
    }


    // need to decide on what to do when the user selects the annotation //
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if(view.annotation is MKUserLocation){
            return
        }

        let customAnnotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("CustomAnnotationView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        
        // need to access the OptionsSingleton to see if this object exists //
        // and then toggle the button titles accordingly //
        if(OptionsSingleton.sharedInstance.existsInSavedList(item: self.currentRestaurant!) == true){
            calloutView.saveButton.setTitle("Unsave", for: UIControlState.normal)
        }else{
            calloutView.saveButton.setTitle("Save", for: UIControlState.normal)
        }
        
        if(OptionsSingleton.sharedInstance.existsInNoGo(item: self.currentRestaurant!) == true){
            calloutView.noGoButton.setTitle("UnBlock", for: UIControlState.normal)
        }else{
            calloutView.noGoButton.setTitle("Block", for: UIControlState.normal)
        }
        
        calloutView.delegate = self
        calloutView.mainLabel.text = customAnnotation.title!

        

        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height * 0.5)
        view.addSubview(calloutView)
        mainMapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
    }
    
    
    // ---- end of annotation stuff ---- //
    
    
    
    
    func returnSaveButtonPressed() {
        self.saveInfoCalled()
    }
    
    func returnMoreInfoButtonPressed() {
        self.moreInfoCalled()
    }
    
    func returnNoGoButtonPressed() {
        self.noGoCalled()
    }
    
    
    
    func returnUnSaveButtonPressed() {
        // this will remove the item from the preferred list //
        self.unSaveInfoCalled()
    }
    
    func returnUnBlockButtonPressed() {
        // this will remove the item from the no go list //
        self.unBlockInfoCalled()
    }
    
    
    func unSaveInfoCalled(){
        let alert = UIAlertController(title: "Do you wish to remove this from your Save List?", message: "Doing so will remove the restaurant from your 'Saved Places' list found in Options.", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
            if(self.currentRestaurant != nil){
                let newSave:PreferredNoGoSaving = PreferredNoGoSaving(info: self.currentRestaurant!)
                newSave.delegate = self
                
                // saves the info to a new or existing array //
                newSave.removeSinglePlace(place: self.currentRestaurant!)
                
                // toggles the save button to unsave //
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UnSave"), object: nil, userInfo: nil)

            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func saveInfoCalled(){
        let alert = UIAlertController(title: "Do you wish to Save this to your 'Saved Places' List?", message: "Doing so will Save the restaurant to your 'Saved Places' list found in Options.  Turning this on in Options will override your search results and will only pull from this list.", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
            if(self.currentRestaurant != nil){
                let newSave:PreferredNoGoSaving = PreferredNoGoSaving(info: self.currentRestaurant!)
                newSave.delegate = self
            
                // checking to see if the item exists in the blocked list and if so, return the index //
                if(newSave.existsInNoGo(itemToCheck: self.currentRestaurant!).0 == true){
                    
                    
                    let alert = UIAlertController(title: "Are you sure?", message: "Saving will remove the item from your 'Blocked Places' List.", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                        
                        let removeFromBlockedList:NoGoSaving = NoGoSaving()
                        removeFromBlockedList.removeSinglePlace(place: self.currentRestaurant!)
                        // toggles the save button to unsave //
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UnBlock"), object: nil, userInfo: nil)
                        
                        // saves the info to a new or existing array //
                        newSave.saveArrayOfPlaces()
                        
                        // toggles the save button to unsave //
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Save"), object: nil, userInfo: nil)
                    })
                    let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okButton)
                    alert.addAction(cancelButton)
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    // saves the info to a new or existing array //
                    newSave.saveArrayOfPlaces()
                    
                    // toggles the save button to unsave //
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Save"), object: nil, userInfo: nil)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    

    
    func noGoCalled(){
        let alert = UIAlertController(title: "Do you wish to save this to your 'Blocked Places' List?", message: "Doing so will Save the restaurant to your 'Blocked Places' list found in Options.  Turning this on in Options will make it so the Restaurant will not appear in your search results.", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
            let noGoSave:NoGoSaving = NoGoSaving(info: self.currentRestaurant!)
            noGoSave.delegate = self
            
            
            // checking to see if the item exists in the blocked list and if so, return the index //
            if(noGoSave.existsInPreferred(itemToCheck: self.currentRestaurant!).0 == true){
                
                
                let alert = UIAlertController(title: "Are you sure?", message: "Saving will remove the item from your 'Saved Places' List.", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                    
                    let removeFromSavedList:PreferredNoGoSaving = PreferredNoGoSaving()
                    removeFromSavedList.removeSinglePlace(place: self.currentRestaurant!)
                    // toggles the save button to unsave //
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UnSave"), object: nil, userInfo: nil)
                    
                    // saves the info to a new or existing array //
                    noGoSave.saveArrayOfPlaces()
                    
                    // toggles the save button to unsave //
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Block"), object: nil, userInfo: nil)
                })
                let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                alert.addAction(cancelButton)
                self.present(alert, animated: true, completion: nil)
                
            }else{
                // saves the info to a new or existing array //
                noGoSave.saveArrayOfPlaces()
                
                // toggles the Block button to unsave //
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Block"), object: nil, userInfo: nil)
            }
    
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func unBlockInfoCalled(){
        let alert = UIAlertController(title: "Do you wish to remove this from your 'Blocked Places' List?", message: "Doing so will remove the restaurant from your 'Blocked Places' list found in Options.", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
            let noGoSave:NoGoSaving = NoGoSaving(info: self.currentRestaurant!)
            noGoSave.delegate = self
            
            // saves the info to a new or existing array //
            noGoSave.removeSinglePlace(place: self.currentRestaurant!)
            
            // toggles the Block button to unsave //
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UnBlock"), object: nil, userInfo: nil)
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func removeStatusNoGo(status: String) {
        
    }
    
    func removeStatus(status: String) {
        
    }
    
    
    @objc func moreInfoCalled(){
        let alert = UIAlertController(title: "What would you like to do?", message: "Make a selection.", preferredStyle: UIAlertControllerStyle.alert)
        let viewInYelpButton = UIAlertAction(title: "View in Yelp", style: UIAlertActionStyle.default) { (action) in
            
            // will send the user to view in Yelp
        }
        let viewInMaps = UIAlertAction(title: "Get Directions", style: UIAlertActionStyle.default) { (action) in
            
            // sends the user to the maps app //
            let location = CLLocationCoordinate2D(latitude: (self.currentRestaurant!.location?.coordinate.latitude)!, longitude: (self.currentRestaurant!.location?.coordinate.longitude)!)
            let placeMark = MKPlacemark(coordinate: location)
            let mapItem = MKMapItem(placemark: placeMark)
            
            mapItem.name = self.currentRestaurant!.name!
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
        let viewInDoorDash = UIAlertAction(title: "View in Doordash", style: UIAlertActionStyle.default) { (action) in
            
            // sends the user to view in Doordash //
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(viewInYelpButton)
        alert.addAction(viewInMaps)
        alert.addAction(viewInDoorDash)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        for views in view.subviews{
            if(views.isKind(of: CustomCalloutView.self)){
                views.removeFromSuperview()
            }
        }
    }
    
    
    
    
    

    
    func returnAllRestuarantInfo(info: [SavePlacesObject]) {
        if(info.count != 0){
            noResults = false
            allRestaurantInfo = info
            
            
            // when a new set of places comes in , I need the list to refresh //
            if(popUpListViewOpen == true){
                if(popUpView != nil){
                    popUpView!.getListOfPlaces(list: allRestaurantInfo)
                }
            }
        }else{
            allRestaurantInfo.removeAll()
            noResults = true
        }
    }

    func reachedTheEndOfSet() {
        newSearch!.newSearch(_location: _location!)
        reachedEndOfSet = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // ---- List view stuff ---- //
    func createListViewPopUp(){
        if(popUpListViewOpen == false){
            popUpListViewOpen = true
            popUpView = ListView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.size.width, height: self.view.frame.size.height / 2))
            popUpView!.delegate = self
            popUpView!.getListOfPlaces(list: allRestaurantInfo)
            if(self.currentRestaurant != nil){
                self.popUpView?.makeItemAppearSelected(item: self.currentRestaurant!)
            }
            
            popUpView!.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            popUpView!.isOpaque = false
            
            self.view.addSubview(popUpView!)
            
        
            UIView.animate(withDuration: 0.3) {
                self.popUpView?.frame = CGRect(x: 0, y: self.view.frame.size.height / 2, width: self.view.frame.size.width, height: self.view.frame.size.height / 2)
                
            }
        }else{
            returnDoneButtonCalled()
        }
    }
    
    
    func returnDoneButtonCalled() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView?.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height / 2)
        }) { (complete) in
            self.popUpView?.removeFromSuperview()
            self.popUpListViewOpen = false
        }
    }
    
    // returns the item selected from the list view //
    func returnSelectedItem(selectedItem: SavePlacesObject) {
        self.currentRestaurant = selectedItem
        self.creatingAnnotationWithInfo(info: self.currentRestaurant!)
        
        if(dropDownInView == true){
            // updating the drop down window //
            if(dropDownView != nil){
            dropDownView?.updateLabels(main: selectedItem.name!, rating: "* \(selectedItem.rating!)", price: "$ \(selectedItem.price!)", distance: "\(selectedItem.distanceFromUser!)mi", open: selectedItem.open!)
            }
        }else{
            UIView.animate(withDuration: 0.50, animations: {
                self.dropDownView?.frame = CGRect(x: 0, y: self.yLocationOfDropDown!, width: self.view.frame.width, height: 100)
                self.dropDownInView = true
                self.dropDownView?.updateLabels(main: selectedItem.name!, rating: "* \(selectedItem.rating!)", price: "$ \(selectedItem.price!)", distance: "\(selectedItem.distanceFromUser!)mi", open: selectedItem.open!)
            
            })
        }
    }
    
    
    // ---- done with list view stuff ---- //
}

