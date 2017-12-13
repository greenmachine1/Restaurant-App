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
        //mainLabel?.clearsContextBeforeDrawing = true
        mainLabel?.backgroundColor = UIColor.blue.withAlphaComponent(0.0)
        mainLabel?.layer.cornerRadius = 5.0
        mainLabel?.clipsToBounds = true
        mainLabel?.layer.isOpaque = true
        mainLabel?.textAlignment = .center
        mainLabel?.textColor = UIColor.white
        
        self.addSubview(mainLabel!)
        
        ratingLabel = UILabel(frame: CGRect(x: 10, y: (self.mainLabel?.frame.origin.y)! + ((self.mainLabel?.frame.size.height)! + 5), width: (self.mainLabel?.frame.width)! / 3, height: 30))
        //ratingLabel?.clearsContextBeforeDrawing = true
        ratingLabel?.backgroundColor = UIColor.blue.withAlphaComponent(0.0)
        ratingLabel?.layer.cornerRadius = 5.0
        ratingLabel?.clipsToBounds = true
        ratingLabel?.layer.isOpaque = true
        ratingLabel?.textAlignment = .center
        ratingLabel?.textColor = UIColor.white
        self.addSubview(ratingLabel!)
        
        distanceLabel = UILabel(frame: CGRect(x: (self.ratingLabel?.frame.origin.x)! + (self.ratingLabel?.frame.size.width)!, y: (self.ratingLabel?.frame.origin.y)!, width: (self.ratingLabel?.frame.size.width)!, height: 30))
        //distanceLabel?.clearsContextBeforeDrawing = true
        distanceLabel?.backgroundColor = UIColor.clear
        distanceLabel?.layer.cornerRadius = 5.0
        distanceLabel?.clipsToBounds = true
        //distanceLabel?.layer.isOpaque = true
        distanceLabel?.textAlignment = .center
        distanceLabel?.textColor = UIColor.white
        self.addSubview(distanceLabel!)
        
        priceLabel = UILabel(frame: CGRect(x: (self.distanceLabel?.frame.origin.x)! + (self.distanceLabel?.frame.size.width)!, y: (self.distanceLabel?.frame.origin.y)!, width: (self.distanceLabel?.frame.size.width)!, height: 30))
        //priceLabel?.clearsContextBeforeDrawing = true
        //priceLabel?.backgroundColor = UIColor.clear
        priceLabel?.layer.cornerRadius = 5.0
        priceLabel?.clipsToBounds = true
        //priceLabel?.layer.isOpaque = true
        priceLabel?.textAlignment = .center
        priceLabel?.textColor = UIColor.white
        self.addSubview(priceLabel!)
        
        openLabel = UILabel(frame: CGRect(x: (self.distanceLabel?.frame.origin.x)!, y: (self.distanceLabel?.frame.origin.y)! + (self.distanceLabel?.frame.size.height)!, width: (self.distanceLabel?.frame.size.width)!, height: 30))
        //openLabel?.clearsContextBeforeDrawing = true
        openLabel?.backgroundColor = UIColor.clear
        openLabel?.layer.cornerRadius = 5.0
        openLabel?.clipsToBounds = true
        //openLabel?.layer.isOpaque = true
        openLabel?.textAlignment = .center
        openLabel?.textColor = UIColor.white
        self.addSubview(openLabel!)
    }

    func updateLabels(main:String, rating:String, price:String, distance:String, open:Bool){

        if(open == true){
            
            self.openLabel?.text = ""
            self.openLabel?.text = "Open Now"
            self.openLabel?.textColor = Colors.sharedInstance.lightBlue
            
        }else{
            
            self.openLabel?.text = ""
            self.openLabel?.text = "Not Open"
            self.openLabel?.textColor = Colors.sharedInstance.lightOrange
            
        }

            if(self.mainLabel != nil){
                self.mainLabel?.text = ""
                self.mainLabel?.text = main
            }
            
            if(self.ratingLabel != nil){
                self.ratingLabel?.text = ""
                self.ratingLabel?.text = rating
            }
            
            if(self.priceLabel != nil){
                
                self.priceLabel?.text = ""
                self.priceLabel?.text = price
            }
            
            if(self.distanceLabel != nil){
                self.distanceLabel?.text = ""
                self.distanceLabel?.text = distance
            }
            
            if(self.openLabel != nil){
                if(open == true){
                    
                    self.openLabel?.text = ""
                    self.openLabel?.text = "Open Now"
                    self.openLabel?.textColor = UIColor.white
                    
                }else{
                    
                    self.openLabel?.text = ""
                    self.openLabel?.text = "Not Open"
                    self.openLabel?.textColor = Colors.sharedInstance.lightOrange
                    
                }
            }
        
        
        
        
        
    }
}
