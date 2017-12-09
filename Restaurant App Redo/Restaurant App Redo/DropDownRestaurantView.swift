//
//  DropDownRestaurantView.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 12/1/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnSwipeGestureDelegate{
    func returnSwipeDirection(leftOrRight:Bool)
}

class DropDownRestaurantView: UIView {
    
    var mainLabel:UILabel?
    var ratingLabel:UILabel?
    var priceLabel:UILabel?
    var distanceLabel:UILabel?
    var openLabel:UILabel?
    
    var delegate:ReturnSwipeGestureDelegate?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawView()
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightGestureRecog))
        swipeRightGesture.direction = .right
        self.addGestureRecognizer(swipeRightGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftGestureRecog))
        swipeLeftGesture.direction = .left
        self.addGestureRecognizer(swipeLeftGesture)
    }
    
    @objc func swipeRightGestureRecog(){
        self.delegate?.returnSwipeDirection(leftOrRight: true)
    }
    
    @objc func swipeLeftGestureRecog(){
        self.delegate?.returnSwipeDirection(leftOrRight: false)
    }
    
    func drawView(){
        
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        
        mainLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width - 20, height: 30))
        mainLabel?.textAlignment = .center
        mainLabel?.textColor = UIColor.white
        
        self.addSubview(mainLabel!)
        
        ratingLabel = UILabel(frame: CGRect(x: 10, y: (self.mainLabel?.frame.origin.y)! + ((self.mainLabel?.frame.size.height)! + 5), width: (self.mainLabel?.frame.width)! / 3, height: 30))
        ratingLabel?.textAlignment = .center
        ratingLabel?.textColor = Colors.sharedInstance.lightBlue
        self.addSubview(ratingLabel!)
        
        distanceLabel = UILabel(frame: CGRect(x: (self.ratingLabel?.frame.origin.x)! + (self.ratingLabel?.frame.size.width)!, y: (self.ratingLabel?.frame.origin.y)!, width: (self.ratingLabel?.frame.size.width)!, height: 30))
        distanceLabel?.textAlignment = .center
        distanceLabel?.textColor = Colors.sharedInstance.lightBlue
        self.addSubview(distanceLabel!)
        
        priceLabel = UILabel(frame: CGRect(x: (self.distanceLabel?.frame.origin.x)! + (self.distanceLabel?.frame.size.width)!, y: (self.distanceLabel?.frame.origin.y)!, width: (self.distanceLabel?.frame.size.width)!, height: 30))
        priceLabel?.textAlignment = .center
        priceLabel?.textColor = Colors.sharedInstance.lightBlue
        self.addSubview(priceLabel!)
        
        openLabel = UILabel(frame: CGRect(x: (self.distanceLabel?.frame.origin.x)!, y: (self.distanceLabel?.frame.origin.y)! + (self.distanceLabel?.frame.size.height)!, width: (self.distanceLabel?.frame.size.width)!, height: 30))
        openLabel?.textAlignment = .center
        openLabel?.textColor = Colors.sharedInstance.lightBlue
        self.addSubview(openLabel!)
    }
    
    
    func updateLabels(main:String, rating:String, price:String, distance:String, open:Bool){
        if(mainLabel != nil){
            mainLabel?.text = ""
            mainLabel?.text = main
        }
        
        if(ratingLabel != nil){
            ratingLabel?.text = ""
            ratingLabel?.text = rating
        }
        
        if(priceLabel != nil){
            priceLabel?.text = ""
            priceLabel?.text = price
        }
        
        if(distanceLabel != nil){
            distanceLabel?.text = ""
            distanceLabel?.text = distance
        }
        
        if(openLabel != nil){
            if(open == true){
                openLabel?.text = ""
                openLabel?.text = "Open Now"
                openLabel?.textColor = Colors.sharedInstance.lightBlue
            }else{
                openLabel?.text = ""
                openLabel?.text = "Not Open"
                openLabel?.textColor = Colors.sharedInstance.lightOrange
            }
        }
    }
    
    
    
    


}
