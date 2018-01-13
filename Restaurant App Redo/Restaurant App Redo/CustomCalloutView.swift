//
//  CustomCalloutView.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 11/4/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

// this is the actual controller for the callout view itself. //
// outlets and the way the view looks can be modified here //


import UIKit
import MapKit

@objc protocol ReturnButtonInfoDelegate{
    func returnSaveButtonPressed()
    func returnUnSaveButtonPressed()
    
    func returnMoreInfoButtonPressed()
    
    func returnNoGoButtonPressed()
    func returnUnBlockButtonPressed()
}

class CustomCalloutView: UIView{
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var noGoButton: UIButton!
    
    var delegate:ReturnButtonInfoDelegate?
    
    var saveButtonToggle:Bool?
    var noGoButtonToggle:Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true

        self.mainLabel.layer.cornerRadius = 5.0
        self.mainLabel.clipsToBounds = true
        self.mainLabel.adjustsFontSizeToFitWidth = true
        
        self.moreInfoButton.layer.cornerRadius = 5.0
        self.moreInfoButton.clipsToBounds = true
        
        self.saveButton.layer.cornerRadius = 5.0
        self.saveButton.clipsToBounds = true
    
        self.noGoButton.layer.cornerRadius = 5.0
        self.noGoButton.clipsToBounds = true
        self.noGoButton.layer.borderColor = Colors.sharedInstance.lightBlue.cgColor
        self.noGoButton.layer.borderWidth = 1.0
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveCalled), name: NSNotification.Name(rawValue: "Save"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.unsaveCalled), name: NSNotification.Name(rawValue: "UnSave"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.blockCalled), name: NSNotification.Name(rawValue: "Block"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.unBlockCalled), name: NSNotification.Name(rawValue: "UnBlock"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadLabels), name: NSNotification.Name(rawValue: "Reload"), object: nil)
        
    }
    
    
    // reloading the labels 
    @objc func reloadLabels(passedInItem:AnyObject){
        if let userInfo = passedInItem.value(forKey: "userInfo"){
            let currentPlace = userInfo as! Dictionary<String, SavePlacesObject>
            if let placeObject = currentPlace["CurrentPlace"]{
                if(OptionsSingleton.sharedInstance.existsInSavedList(item: placeObject)){
                    self.saveCalled()
                }else{
                    self.unsaveCalled()
                }
                
                if(OptionsSingleton.sharedInstance.existsInNoGo(item: placeObject)){
                    self.blockCalled()
                }else{
                    self.unBlockCalled()
                }
            }
        }
    }
    
 
 
    // Notifications called //
    @objc func saveCalled(){
        self.saveButton.setTitle("UnSave", for: UIControlState.normal)
    }
    
    @objc func unsaveCalled(){
        self.saveButton.setTitle("Save", for: UIControlState.normal)
    }
    
    @objc func blockCalled(){
        self.noGoButton.setTitle("UnBlock", for: UIControlState.normal)
    }
    
    @objc func unBlockCalled(){
        self.noGoButton.setTitle("Block", for: UIControlState.normal)
    }
    
    // ---- //
    
    
    
    
    @IBAction func moreInfoOnClick(_ sender: UIButton) {
        self.delegate?.returnMoreInfoButtonPressed()
    }
    
    @IBAction func saveButtonOnClick(_ sender: UIButton) {
        if(sender.title(for: UIControlState.normal) == "Save"){
            self.delegate?.returnSaveButtonPressed()
        }else{
            self.delegate?.returnUnSaveButtonPressed()
        } 
    }

    @IBAction func noGoOnClick(_ sender: UIButton) {
        if(sender.title(for: UIControlState.normal) == "Block"){
            self.delegate?.returnNoGoButtonPressed()
        }else{
            self.delegate?.returnUnBlockButtonPressed()
        }
        
    }
}
