//
//  NewOptionsViewController.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 1/21/18.
//  Copyright © 2018 Cory Green. All rights reserved.
//

import UIKit
import MapKit

class NewOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        self.mainMapView.layer.cornerRadius = 30
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
        
        
    }
    
    func passInLocation(location:CLLocation){
        currentLocation = location
        
    }
    
    @IBAction func distanceSliderChangeValue(_ sender: UISlider) {
        let distanceValue = Int(sender.value)
        self.distanceLabel.text = "\(distanceValue) Miles"
        
        self.updateMapView(distance: distanceValue)
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
        
        let backgroundView:UIView = UIView()
        
        for views in minRatingView.subviews{
            if(views.tag == 10){
                views.removeFromSuperview()
            }
        }
        backgroundView.frame = CGRect(x: 0, y: 0, width: sender.tag * 60 + Int(sender.frame.size.width), height: 70)
        
        backgroundView.backgroundColor = Colors.sharedInstance.lightOrange
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height / 2
        backgroundView.clipsToBounds = true
        backgroundView.tag = 10
        
        self.minRatingView.addSubview(backgroundView)
        self.minRatingView.sendSubview(toBack: backgroundView)
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
        for buttons in self.maxPriceView.subviews{
            if(buttons is UIButton){
                buttons.backgroundColor = Colors.sharedInstance.lightBlue
            }
        }
        
        sender.backgroundColor = Colors.sharedInstance.lightOrange
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
}
