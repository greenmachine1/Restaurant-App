//
//  PopUpSearchView.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 1/8/18.
//  Copyright © 2018 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnSearchPopUpViewDelegate{
    func doneButtonClicked()
}

class PopUpSearchView: UIView, UITextFieldDelegate {
    
    var delegate:ReturnSearchPopUpViewDelegate?
    var doneButton:UIButton?
    var mainTextField:UITextField?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawPopUpView()
    }
    
    func drawPopUpView(){
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        
        doneButton = UIButton(frame: CGRect(x: self.frame.size.width - 110, y: 10, width: 100, height: 30))
        doneButton!.setTitle("Done", for: UIControlState.normal)
        doneButton!.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton!.addTarget(self, action: #selector(self.doneButtonOnClick), for: UIControlEvents.touchUpInside)
        doneButton!.backgroundColor = Colors.sharedInstance.lightBlue
        doneButton!.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        doneButton!.layer.cornerRadius = 5.0
        doneButton!.clipsToBounds = true
        self.addSubview(doneButton!)
        
        
        mainTextField = UITextField(frame: CGRect(x: 10, y: (self.doneButton?.frame.origin.y)! + ((self.doneButton?.frame.size.height)! + 10), width: self.frame.size.width - 20, height: 30))
        mainTextField?.delegate = self
        mainTextField?.layer.cornerRadius = 5.0
        mainTextField?.clipsToBounds = true
        mainTextField?.backgroundColor = UIColor.white
        self.addSubview(mainTextField!)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func doneButtonOnClick(){
        self.mainTextField?.resignFirstResponder()
        self.delegate?.doneButtonClicked()
        
    }
    
    
    


}
