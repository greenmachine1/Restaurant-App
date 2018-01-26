//
//  NewOptionsViewController.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 1/21/18.
//  Copyright © 2018 Cory Green. All rights reserved.
//

import UIKit
import MapKit

class NewOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReturnKeywordsDelegate {

    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var minRatingView: UIView!
    @IBOutlet weak var maxPriceView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    
    var currentLocation:CLLocation?
    var _region:MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // distance stuff //
        self.mainMapView.layer.cornerRadius = self.mainMapView.frame.size.width / 2
        self.mainMapView.layer.borderColor = Colors.sharedInstance.lightBlue.cgColor
        self.mainMapView.layer.borderWidth = 5.0
        
        self.distanceSlider.tintColor = Colors.sharedInstance.lightBlue
        
        self.distanceLabel.text = "5 Miles"
        
        
        self.updateMapView(distance: 5)
        
        
        // min rating stuff //
        self.minRatingView.layer.cornerRadius = self.minRatingView.frame.size.height / 2
        self.minRatingView.clipsToBounds = true
        self.drawStarButtons()
        
        // max price stuff //
        self.maxPriceView.layer.cornerRadius = self.maxPriceView.frame.size.height / 2
        self.maxPriceView.clipsToBounds = true
        self.drawDollarButtons()
        
        
        
        // keywords, saved places, blocked places //
        self.mainTableView.layer.cornerRadius = 30
        self.mainTableView.clipsToBounds = true
        self.mainTableView.layer.borderColor = Colors.sharedInstance.lightBlue.cgColor
        self.mainTableView.layer.borderWidth = 5.0
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self

        self.loadUserDefaults()
        
        let undoButton:UIBarButtonItem = UIBarButtonItem(title: "Undo", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.barButtonSelected))
        
        self.navigationItem.rightBarButtonItem = undoButton
    }
    
    @objc func barButtonSelected(){
        OptionsSingleton.sharedInstance.deleteAllOptions()
        loadUserDefaults()
    }
    
    func loadUserDefaults(){
        // upon loading, load the default set values //
        self.makeSelectedRoundedBox(_view: self.minRatingView, position: OptionsSingleton.sharedInstance.getRating())
        self.makeSelectedRoundedBox(_view: self.maxPriceView, position: OptionsSingleton.sharedInstance.getPrice())
        self.distanceSlider.setValue(Float(OptionsSingleton.sharedInstance.getDistance()), animated: true)
        self.updateMapView(distance: OptionsSingleton.sharedInstance.getDistance())
        self.distanceLabel.text = "\(OptionsSingleton.sharedInstance.getDistance()) Miles"
    }
    
    func passInLocation(location:CLLocation){
        currentLocation = location
    }
    
    @IBAction func distanceSliderChangeValue(_ sender: UISlider) {
        let distanceValue = Int(sender.value)
        self.distanceLabel.text = "\(distanceValue) Miles"
        
        self.updateMapView(distance: distanceValue)
        
        OptionsSingleton.sharedInstance.setDistance(distance: distanceValue)
        
        
    }
    
    
    func updateMapView(distance:Int){
        let locationCoordinate = CLLocationCoordinate2D(latitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!)
        _region = MKCoordinateRegionMakeWithDistance(locationCoordinate, Double(1609 * distance), Double(1609 * distance))
        mainMapView.setRegion(_region!, animated: true)
    }
    
    
    
    
    
    // creating star buttons for the rating view //
    func drawStarButtons(){
        for i in 0..<5{
            let starButton:UIButton = UIButton(frame: CGRect(x: i * 60, y: 5, width: 60, height: 60))
            starButton.setImage(UIImage(named: "Star"), for: UIControlState.normal)
            starButton.tag = i
            starButton.addTarget(self, action: #selector(self.ratingButtonsOnClick), for: UIControlEvents.touchUpInside)
            starButton.layer.cornerRadius = starButton.frame.size.height / 2
            self.minRatingView.addSubview(starButton)
        }
    }
    
    @objc func ratingButtonsOnClick(sender:UIButton){
        self.makeSelectedRoundedBox(_view: minRatingView, position: sender.tag)
        OptionsSingleton.sharedInstance.setRating(rating: sender.tag)
    }
    
    
    // creating price buttons for the max price view //
    func drawDollarButtons(){
        for i in 0..<5{
            let dollarButton:UIButton = UIButton(frame: CGRect(x: i * 60, y: 5, width: 60, height: 60))
            dollarButton.setTitle("\(i)", for: UIControlState.normal)
            dollarButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            dollarButton.tag = i
            dollarButton.addTarget(self, action: #selector(self.priceButtonsOnClick), for: UIControlEvents.touchUpInside)
            dollarButton.layer.cornerRadius = dollarButton.frame.size.height / 2
            
            self.maxPriceView.addSubview(dollarButton)
        }
    }
    
    @objc func priceButtonsOnClick(sender:UIButton){
        self.makeSelectedRoundedBox(_view: maxPriceView, position: sender.tag)
        OptionsSingleton.sharedInstance.setPrice(price: sender.tag)
    }
    
    
    
    func makeSelectedRoundedBox(_view:UIView, position:Int){
        let backgroundView:UIView = UIView()
        
        for views in _view.subviews{
            if(views.tag == 10){
                views.removeFromSuperview()
            }
        }
        backgroundView.frame = CGRect(x: 0, y: 0, width: position * 60 + 60, height: 70)
        backgroundView.backgroundColor = Colors.sharedInstance.lightOrange
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height / 2
        backgroundView.clipsToBounds = true
        backgroundView.tag = 10
        
        _view.addSubview(backgroundView)
        _view.sendSubview(toBack: backgroundView)
        
    }
    
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsCustomCell") as! OptionsTableViewCell
        
        if(indexPath.row == 0){
            cell.mainLabel.text = "Keywords"
        }else if(indexPath.row == 1){
            cell.mainLabel.text = "Saved Places"
        }else if(indexPath.row == 2){
            cell.mainLabel.text = "Blocked Places"
        }
        
        return cell
    }
    
    
    // will be injecting different sets of data into each of the same table views //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            // keywords //
            let keywordsView = self.storyboard?.instantiateViewController(withIdentifier: "Keywords") as! KeywordsViewController
            keywordsView.delegate = self
            self.navigationController?.pushViewController(keywordsView, animated: true)
            
        }else if(indexPath.row == 1){
            
            // preferred //
            let preferredView = self.storyboard?.instantiateViewController(withIdentifier: "PrefNoGoKey") as! PreferredNoGoViewController
            
            self.navigationController?.pushViewController(preferredView, animated: true)
            
        }else{
            // no go //
            let noGoView = self.storyboard?.instantiateViewController(withIdentifier: "NoGo") as! NoGoViewController
            self.navigationController?.pushViewController(noGoView, animated: true)
        }
    }
    
    
    
    func returnKeywords(keywords: [String]) {
        // saving the keywords //
        OptionsSingleton.sharedInstance.setKeyWords(keywords: keywords)
    }
}
