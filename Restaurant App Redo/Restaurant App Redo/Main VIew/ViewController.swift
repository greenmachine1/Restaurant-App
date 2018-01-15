//
//  ViewController.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/17/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, ReturnLocationDelegate, /*ReturnRestaurauntInfoAndLocationDelegate,*/ ReturnOptionsUpdatedDelegate, MKMapViewDelegate, ListViewDelegate, ReturnButtonInfoDelegate, ReturnSaveOfPreferredPlaces, ReturnSaveOfNoGoPlaces, ReturnSwipeGestureDelegate, ReturnButtonPressedDelegate, ReturnRestaurauntInfoAndLocation, ReturnRecenterButtonsDelegate, ReturnSearchPopUpViewDelegate{

    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var workingIndicator: UIActivityIndicatorView!
    
    var getLocation:LocationServices?
    var _location:CLLocation?
    var _region:MKCoordinateRegion?
    
    var reachedEndOfSet:Bool?
    var optionsUpdatedBool:Bool = false
    var noResults:Bool = false
    var popUpListViewOpen:Bool = false

    var newSearch:GatheringPlacesNear?
    var allRestaurantInfo:[SavePlacesObject] = []
    var currentRestaurant:SavePlacesObject?
    
    var popUpView:ListView?
    
    var listOfPlaces:UIBarButtonItem?
    var optionsButton:UIBarButtonItem?
    
    var annotation:CustomAnnotation?
    
    var dropDownView:DropDownRestaurantView?
    var dropDownInView:Bool = false
    
    var nextAndPreviousButtons:NextAndPreviousButtonView?
    var nextAndPreviousButtonsOut:Bool?
    
    var recenterButtonCluster:RecenterButtonsView?
    
    var searchPopUpView:PopUpSearchView?
    var searchViewIsPresent:Bool = false
    
    var newDefaultLocationSelected:Bool = false
    
    
    // getting the nav bar height //
    var yLocationOfDropDown:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // ---- initial setup stuff ---- //
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDropDownMenuUponReload), name: .UIApplicationDidBecomeActive, object: nil)
        
        // ---- being notified when the keyboard is out when searching ---- //
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardIsOut), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        // ---- being notified when the keyboard has gone back in when searching ---- //
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardIsIn), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        
        // setting the reached end of set to false //
        reachedEndOfSet = false
        
        getLocation = LocationServices()
        getLocation!.delegate = self
        getLocation!.startLocationServices()
        
        mainMapView.showsUserLocation = true
        mainMapView.delegate = self
        
        
        OptionsSingleton.sharedInstance.delegate = self
        
        
        
        // creating the next and previous buttons //
        nextAndPreviousButtons = NextAndPreviousButtonView(frame: CGRect(x: 0, y: self.view.frame.origin.y + (self.view.frame.size.height - 70), width: self.view.frame.size.width, height: 70))
        nextAndPreviousButtons?.delegate = self
        self.view.addSubview(nextAndPreviousButtons!)
        
        
        
        
        // Setting the height from the top of the navbar to the beginning of the usable //
        // screen area //
        yLocationOfDropDown = self.view.frame.origin.y + (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        
        //self.reCenterButton.layer.cornerRadius = self.reCenterButton.frame.size.height / 2
        //self.reCenterButton.clipsToBounds = true
        
        self.workingIndicator.stopAnimating()
        self.workingIndicator.hidesWhenStopped = true
        
        
       
        

        
        
        // ---- adding navigation bar items ---- //
        optionsButton = UIBarButtonItem(image: UIImage(named: "OptionsIcon"), style: UIBarButtonItemStyle.done, target: self, action: #selector(self.navBarButtonsOnClick))
        optionsButton?.tintColor = Colors.sharedInstance.lightBlue
        optionsButton!.tag = 0

        listOfPlaces = UIBarButtonItem(image: UIImage(named: "ListIcon"), style: UIBarButtonItemStyle.done, target: self, action: #selector(self.navBarButtonsOnClick))
        listOfPlaces?.tintColor = Colors.sharedInstance.lightBlue
        listOfPlaces!.tag = 1

        self.navigationItem.rightBarButtonItems = [optionsButton!, listOfPlaces!]
        
        

        // ---- adding in a drop down nav bar box ---- //
        dropDownView = DropDownRestaurantView(frame: CGRect(x: 0, y: -yLocationOfDropDown!, width: self.view.frame.width, height: 100))
        dropDownView?.delegate = self
        dropDownView!.backgroundColor = UIColor.black
        dropDownView!.isOpaque = true

        self.view.addSubview(dropDownView!)
        
        // ---- creating the recenter button cluster which holds the recenter button and adding a new default location ---- //
        // ---- buttons ---- //
        recenterButtonCluster = RecenterButtonsView(frame: CGRect(x: (self.dropDownView?.frame.origin.x)! + ((self.dropDownView?.frame.size.width)! - 60), y: (self.dropDownView?.frame.origin.y)! + (self.dropDownView?.frame.size.height)! + yLocationOfDropDown! + 20, width: 50, height: 100))
        recenterButtonCluster?.delegate = self
        recenterButtonCluster?.backgroundColor = Colors.sharedInstance.lightBlue
        recenterButtonCluster?.layer.cornerRadius = (self.recenterButtonCluster?.frame.size.width)! / 2
        recenterButtonCluster?.clipsToBounds = true
        recenterButtonCluster?.layer.borderColor = UIColor.white.cgColor
        recenterButtonCluster?.layer.borderWidth = 1.0
        
        
        self.view.addSubview(recenterButtonCluster!)
        
        // ---- instantiating the search pop up view ---- //
        searchPopUpView = PopUpSearchView(frame: CGRect(x: 0, y: self.view.frame.origin.y + self.view.frame.size.height, width: self.view.frame.size.width, height: (self.view.frame.size.height / 2) + 20))
        searchPopUpView?.delegate = self
        searchPopUpView!.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        searchPopUpView!.isOpaque = false
        
        self.view.addSubview(searchPopUpView!)
        
    }
    
    
    
    func recenterButtonClicked() {
        self.nextAndPreviousButtons?.slideNextButtonBackToFullLength()
        self.nextAndPreviousButtons?.updateNextButtonTitle(title: "Go!")
        self.mainMapView.showsUserLocation = true
        self.raiseDropDownView()
        newDefaultLocationSelected = false
        mainMapView.removeAnnotations(mainMapView.annotations)
        getLocation!.startLocationServices()
    }
    
    
    // need to nudge the view up while the keyboard is out //
    @objc func keyboardIsOut(notification:Notification){
        if(searchViewIsPresent == true){
            if let sizeOfKeyboard = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
                let keyboardHeight = sizeOfKeyboard.height
                print(keyboardHeight)
                UIView.animate(withDuration: 0.3, animations: {
                    self.searchPopUpView?.frame = CGRect(x: 0, y:self.view.frame.origin.y + ((self.view.frame.size.height / 2) - 20), width: self.view.frame.size.width, height: self.view.frame.size.height / 2)
                })
            }
        }
    }
    
    // resetting the view //
    @objc func keyboardIsIn(notification:Notification){
        if(searchViewIsPresent == true){
            self.newCenterButtonClicked()
        }
    }
    
    
    // this is from the define a new location to search from button click //
    func newCenterButtonClicked() {
        // bringing the view into place //
        UIView.animate(withDuration: 0.3, animations: {
            self.searchPopUpView?.frame = CGRect(x: 0, y: self.view.frame.origin.y + ((self.view.frame.size.height / 2) - 20), width: self.view.frame.size.width, height: (self.view.frame.size.height / 2) + 20)
        }) { (complete) in
            // do something once complete //
            self.searchViewIsPresent = true
        }
    }
    
    // return button from the pop up search view used to dismiss that view //
    func doneButtonClicked() {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchPopUpView?.frame = CGRect(x: 0, y: self.view.frame.origin.y + self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height / 2)
        }) { (complete) in
            // do something once complete //
            self.searchViewIsPresent = false
        }
    }
    
    // alert to tell the user that the search results brought back nothing //
    func sendBackAlert(title: String, alertString: String) {
        let alert = UIAlertController(title: title, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    // this presents the user with the option to save the place as the new default //
    func sendBackInfo(title: String, location: CLLocation) {
        let alert = UIAlertController(title: "Location Found!", message: "Do you want to use \(title) as your new location?", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (action) in
            
            
            // need to set the new default position //
            self._location = location
            self.newDefaultLocationSelected = true
            self.returnLocation(location: self._location!, cameFromNewDefaultLocation:true, title:title)
            
            // sending info back to the pop up view for history info //
            self.searchPopUpView?.placeSelectedAndShouldBeAddedToHistory(name: title, location: location)
            self.raiseDropDownView()
            self.nextAndPreviousButtons?.updateNextButtonTitle(title: "Go!")
            self.doneButtonClicked()
            
        }
        let noButton = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okButton)
        alert.addAction(noButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    // buttons return pressed function //
    func returnButtonPressed(trueForNextFalseForPrevious: Bool) {
        self.goButtonClickedOrSwipedRight(swipedLeftIsFalseSwipedRightIsTrue: trueForNextFalseForPrevious)
    }
    
    
    func lowerDropDownView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.dropDownView?.frame = CGRect(x: 0, y: self.yLocationOfDropDown!, width: self.view.frame.width, height: 100)
            self.recenterButtonCluster?.frame = CGRect(x: (self.dropDownView?.frame.origin.x)! + ((self.dropDownView?.frame.size.width)! - 60), y: (self.dropDownView?.frame.origin.y)! + (self.dropDownView?.frame.size.height)! + 20, width: 50, height: 100)
            self.dropDownInView = true
        }) { (complete) in
            self.dropDownInView = true
        }
    }
    
    // pulling back the drop down view //
    func raiseDropDownView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.dropDownView?.frame = CGRect(x: 0, y: -self.yLocationOfDropDown!, width: self.view.frame.width, height: 100)
            
            // bringing the recenter button cluster back up to the top of the screen //
            self.recenterButtonCluster?.frame = CGRect(x: (self.dropDownView?.frame.origin.x)! + ((self.dropDownView?.frame.size.width)! - 60), y: (self.dropDownView?.frame.origin.y)! + (self.dropDownView?.frame.size.height)! + self.self.yLocationOfDropDown! + 20, width: 50, height: 100)
        }) { (completed) in
            self.dropDownInView = false
        }
    }
    
    
    
    
    
    
    
    // this is a bug in iOS 11.2 //
    override func viewWillDisappear(_ animated: Bool) {
        self.optionsButton?.isEnabled = false
        self.optionsButton?.isEnabled = true
    }
    
    
    
    // when a new set of places comes in this gets updated //
    func updateToPlaces() {
        let info = OptionsSingleton.sharedInstance.getPlaces()
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
    
    
    @objc func updateDropDownMenuUponReload(){
        if(dropDownInView == true){
            if(dropDownView != nil){
                // updating the drop down window //
                if(self.currentRestaurant != nil){

                    dropDownView?.newUpdateLabels(main: self.currentRestaurant!.name!, rating: self.currentRestaurant!.rating!, price: self.currentRestaurant!.price!, distance: (self.currentRestaurant?.distanceFromUser!)!, open: (self.currentRestaurant?.open!)!)
                }
            }
        }
    }
    
    
    // when the user swipes left or right on the top bar //
    // do stuff //
    func returnSwipeDirection(leftOrRight: Bool) {
        self.goButtonClickedOrSwipedRight(swipedLeftIsFalseSwipedRightIsTrue: leftOrRight)
    }
    
    
    
    
    
    func returnOptionsDidChange() {
        optionsUpdatedBool = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(optionsUpdatedBool == true){
            if(newDefaultLocationSelected == false){
                getLocation?.startLocationServices()
            }else{
                self.raiseDropDownView()
                newSearch?.search(location: _location!)
            }
            optionsUpdatedBool = false
            
            self.raiseDropDownView()
            self.nextAndPreviousButtons?.slideNextButtonBackToFullLength()
            self.nextAndPreviousButtons?.updateNextButtonTitle(title: "Go!")
            
            if(dropDownInView == true){
                self.raiseDropDownView()
            }
        }
        for annotation in self.mainMapView.annotations{
            if(annotation.isKind(of: CustomAnnotation.self)){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Reload"), object: nil, userInfo: ["CurrentPlace":self.currentRestaurant!])
            }
        }
    }

    
    
    @objc func navBarButtonsOnClick(sender:UIBarButtonItem){
        
        // options touched //
        if(sender.tag == 0){
            let optionsViewController = self.storyboard?.instantiateViewController(withIdentifier: "Options") as? OptionsViewController
            self.navigationController?.pushViewController(optionsViewController!, animated: true)
        // list view touched //
        }else if(sender.tag == 1){
            self.createListViewPopUp()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // returning the location //
    func returnLocation(location: CLLocation, cameFromNewDefaultLocation:Bool, title:String) {
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        _location = location
        
        // saving the new location to the users defaults to be used elsewhere //
        OptionsSingleton.sharedInstance.saveDefaultLocation(location: _location!)
        
        _region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mainMapView.setRegion(_region!, animated: true)
        if(cameFromNewDefaultLocation == true){
            
            let newDefaultLocationAnnotation = MKPointAnnotation()
            newDefaultLocationAnnotation.title = title
            newDefaultLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            self.mainMapView.addAnnotation(newDefaultLocationAnnotation)
            
            self.mainMapView.showsUserLocation = false
        }else{
            self.mainMapView.showsUserLocation = true
        }

        newSearch = GatheringPlacesNear()
        newSearch?.delegate = self
        
        if(_location != nil){
            newSearch!.search(location: _location!)
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // returning the place info //
    func returnRestaurantInfo(info: SavePlacesObject) {
        currentRestaurant = info
        dropDownView?.newUpdateLabels(main: info.name!, rating: info.rating!, price: info.price!, distance: info.distanceFromUser!, open: info.open!)
        
        if(dropDownInView == false){
            self.lowerDropDownView()
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
        
        var _coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (info.location?.coordinate.latitude)!, longitude: (info.location?.coordinate.longitude)!)
        _region = MKCoordinateRegionMakeWithDistance(_coordinate, 1000, 1000)
        mainMapView.setRegion(_region!, animated: true)
        
        // making a callout view for the annotation //
        annotation = CustomAnnotation(_title: info.name!, _coordinate: _coordinate)
        
        
        var centerCoordinate = _coordinate
        centerCoordinate.latitude -= self.mainMapView.region.span.latitudeDelta * -0.20
        self.mainMapView.setCenter(centerCoordinate, animated: true)
        
        
        mainMapView.addAnnotation(annotation!)
    
    }

    
    
    
    
    
    
    
    
    
    // indicator as to whether or not the network is searching //
    func working(yesNo: Bool) {
        if(yesNo == true){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.workingIndicator.startAnimating()
                self.mainMapView.isUserInteractionEnabled = false
                
                self.listOfPlaces?.isEnabled = false
                self.nextAndPreviousButtons?.slideNextButtonBackToFullLength()
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.workingIndicator.stopAnimating()
                self.mainMapView.isUserInteractionEnabled = true
                
                self.listOfPlaces?.isEnabled = true
                
                if(self.reachedEndOfSet == true){
                    self.newSearch?.gettingNextRestaurant()
                    self.reachedEndOfSet = false
                }
                
            }
        }
    }

    
    
    func goButtonClickedOrSwipedRight(swipedLeftIsFalseSwipedRightIsTrue:Bool){
        
        // swiped right //
        if(swipedLeftIsFalseSwipedRightIsTrue == true){
            if(noResults == false){
            
                newSearch?.gettingNextRestaurant()
                self.mainMapView.showsUserLocation = false

                nextAndPreviousButtons?.updateNextButtonTitle(title: "Next")
                nextAndPreviousButtonsOut = true
                if(newSearch!.numberOn != nil){
                    if(newSearch!.numberOn! >= 1){
                        nextAndPreviousButtons?.makeNextAndPreviousButtonsHalfWidth()
                        nextAndPreviousButtons?.updateNextButtonTitle(title: "Next")
                        nextAndPreviousButtonsOut = true
                    }
                }
            }else{
                let alert:UIAlertController = UIAlertController(title: "No results Found", message: "Try adjusting your options for better results", preferredStyle: UIAlertControllerStyle.alert)
                let okButton:UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        // swiped left //
        }else{
            if(noResults == false){
                if(newSearch!.numberOn != nil){
                    print(newSearch!.numberOn!)
                    if(newSearch!.numberOn! != 1){
                        newSearch?.gettingPreviousRestaurant()
                        self.mainMapView.showsUserLocation = false
                    }else{
                        newSearch?.gettingPreviousRestaurant()
                        nextAndPreviousButtons?.slideNextButtonBackToFullLength()
                        nextAndPreviousButtons?.updateNextButtonTitle(title: "Go!")
                        nextAndPreviousButtonsOut = false
                    }
                }
            }
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
        if(view.annotation is MKUserLocation || view.annotation is MKPointAnnotation){
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

        var centerCoordinate = customAnnotation.coordinate
        centerCoordinate.latitude -= self.mainMapView.region.span.latitudeDelta * -0.20
        self.mainMapView.setCenter(centerCoordinate, animated: true)
        

        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height * 0.50)
        view.addSubview(calloutView)
        mainMapView.setCenter(centerCoordinate, animated: true)
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
        let alert = UIAlertController(title: "Do you wish to Save this to your 'Saved Places' List?", message: "Doing so will Save the restaurant to your 'Saved Places' list found in Options.", preferredStyle: UIAlertControllerStyle.alert)
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
        let alert = UIAlertController(title: "Do you wish to save this to your 'Blocked Places' List?", message: "Doing so will Save the restaurant to your 'Blocked Places' list found in Options.", preferredStyle: UIAlertControllerStyle.alert)
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
    
    
    
    

    
    
    
    

    func reachedTheEndOfSet() {
        newSearch?.search(location: _location!)
        reachedEndOfSet = true
    }
    
    
    func reachedBeginningOfSet() {
        self.nextAndPreviousButtons?.slideNextButtonBackToFullLength()
    }
    
    
    func nextButtonAndPreviousButtonsAreOut(bothOut: Bool) {
        nextAndPreviousButtonsOut = bothOut
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
                dropDownView?.newUpdateLabels(main: selectedItem.name!, rating: selectedItem.rating!, price: selectedItem.price!, distance: selectedItem.distanceFromUser!, open: selectedItem.open!)
            }
        }else{
            self.lowerDropDownView()
            self.dropDownView?.newUpdateLabels(main: selectedItem.name!, rating: selectedItem.rating!, price: selectedItem.price!, distance: selectedItem.distanceFromUser!, open: selectedItem.open!)
        }
    }
    
    
    // ---- done with list view stuff ---- //
}

