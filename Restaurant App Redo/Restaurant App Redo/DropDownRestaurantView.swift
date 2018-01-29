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
    var ratingLabelText:UILabel?
    var priceLabel:UILabel?
    var priceLabelText:UILabel?
    var distanceLabel:UILabel?
    var openLabel:UILabel?

    var delegate:ReturnSwipeGestureDelegate?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
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

        mainLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width - 20, height: 30))
        mainLabel?.backgroundColor = UIColor.clear
        mainLabel?.layer.cornerRadius = 5.0
        mainLabel?.clipsToBounds = true
        mainLabel?.layer.isOpaque = true
        mainLabel?.textAlignment = .center
        mainLabel?.textColor = Colors.sharedInstance.lightBlue
        
        self.addSubview(mainLabel!)
        
        ratingLabel = UILabel(frame: CGRect(x: 10, y: (self.mainLabel?.frame.origin.y)! + ((self.mainLabel?.frame.size.height)! + 5), width: (self.mainLabel?.frame.width)! / 3, height: 30))
        ratingLabel?.backgroundColor = UIColor.clear
        ratingLabel?.layer.cornerRadius = 5.0
        ratingLabel?.clipsToBounds = true
        ratingLabel?.layer.isOpaque = true
        ratingLabel?.textAlignment = .center
        ratingLabel?.textColor = UIColor.white
        ratingLabel?.text = "Rating"
        self.addSubview(ratingLabel!)
        
        ratingLabelText = UILabel(frame: CGRect(x: 10, y: (self.ratingLabel?.frame.origin.y)! + (self.ratingLabel?.frame.size.height)!, width: (self.ratingLabel?.frame.size.width)!, height: 30))
        ratingLabelText?.backgroundColor = UIColor.clear
        ratingLabelText?.layer.cornerRadius = 5.0
        ratingLabelText?.clipsToBounds = true
        ratingLabelText?.layer.isOpaque = true
        ratingLabelText?.textAlignment = .center
        ratingLabelText?.textColor = UIColor.white
        self.addSubview(ratingLabelText!)
        
        
        distanceLabel = UILabel(frame: CGRect(x: (self.ratingLabel?.frame.origin.x)! + (self.ratingLabel?.frame.size.width)!, y: (self.ratingLabel?.frame.origin.y)!, width: (self.ratingLabel?.frame.size.width)!, height: 30))
        distanceLabel?.backgroundColor = UIColor.clear
        distanceLabel?.layer.cornerRadius = 5.0
        distanceLabel?.clipsToBounds = true
        distanceLabel?.layer.isOpaque = true
        distanceLabel?.textAlignment = .center
        distanceLabel?.textColor = UIColor.white
        self.addSubview(distanceLabel!)
        
        priceLabel = UILabel(frame: CGRect(x: (self.distanceLabel?.frame.origin.x)! + (self.distanceLabel?.frame.size.width)!, y: (self.distanceLabel?.frame.origin.y)!, width: (self.distanceLabel?.frame.size.width)!, height: 30))
        priceLabel?.backgroundColor = UIColor.clear
        priceLabel?.layer.cornerRadius = 5.0
        priceLabel?.clipsToBounds = true
        priceLabel?.layer.isOpaque = true
        priceLabel?.textAlignment = .center
        priceLabel?.textColor = UIColor.white
        priceLabel?.text = "Price"
        self.addSubview(priceLabel!)
        
        
        priceLabelText = UILabel(frame: CGRect(x: (self.priceLabel?.frame.origin.x)!, y: (self.priceLabel?.frame.origin.y)! + (self.priceLabel?.frame.size.height)!, width: (self.priceLabel?.frame.size.width)!, height: 30))
        priceLabelText?.backgroundColor = UIColor.clear
        priceLabelText?.layer.cornerRadius = 5.0
        priceLabelText?.clipsToBounds = true
        priceLabelText?.layer.isOpaque = true
        priceLabelText?.textAlignment = .center
        priceLabelText?.textColor = UIColor.white
        self.addSubview(priceLabelText!)
        
        openLabel = UILabel(frame: CGRect(x: (self.distanceLabel?.frame.origin.x)!, y: (self.distanceLabel?.frame.origin.y)! + (self.distanceLabel?.frame.size.height)!, width: (self.distanceLabel?.frame.size.width)!, height: 30))
        openLabel?.backgroundColor = UIColor.clear
        openLabel?.layer.cornerRadius = 5.0
        openLabel?.clipsToBounds = true
        openLabel?.layer.isOpaque = true
        openLabel?.textAlignment = .center
        openLabel?.textColor = UIColor.white
        self.addSubview(openLabel!)
    }
    
    func newUpdateLabels(main:String, rating:Double, price:Int, distance:Int, open:Bool){
        if(open == true){
            self.openLabel?.text = "Open Now"
            self.openLabel?.textColor = Colors.sharedInstance.lightBlue
        }else{
            self.openLabel?.text = "Not Open"
            self.openLabel?.textColor = Colors.sharedInstance.lightOrange
        }
        
        if(self.mainLabel != nil){
            self.mainLabel?.text = main
        }
        
        if(self.ratingLabel != nil){
            
            let tempRating = Int(rating)
            if(tempRating == 1){
                self.ratingLabelText?.text = "*"
            }else if(tempRating == 2){
                self.ratingLabelText?.text = "**"
            }else if(tempRating == 3){
                self.ratingLabelText?.text = "***"
            }else if(tempRating == 4){
                self.ratingLabelText?.text = "****"
            }else if(tempRating == 5){
                self.ratingLabelText?.text = "*****"
            }
            
            
            //self.ratingLabelText?.text = "\(rating)"
        }
        
        if(self.priceLabel != nil){
            
            if(price == 0){
                self.priceLabelText?.text = "$"
            }else if(price == 1){
                self.priceLabelText?.text = "$$"
            }else if(price == 2){
                self.priceLabelText?.text = "$$$"
            }else if(price == 3){
                self.priceLabelText?.text = "$$$$"
            }else if(price == 4){
                self.priceLabelText?.text = "$$$$$"
            }
            
            
            //self.priceLabelText?.text = "\(price)"
        }
        
        if(self.distanceLabel != nil){
            if(distance < 1){
                self.distanceLabel?.text = "<1 Mile Away"
            }else if(distance == 1){
                self.distanceLabel?.text = "1 Mile Away"
            }else{
                self.distanceLabel?.text = "\(distance) Miles Away"
            }
        }
    }
}
