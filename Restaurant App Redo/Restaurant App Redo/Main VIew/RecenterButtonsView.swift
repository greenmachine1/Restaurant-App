//
//  RecenterButtonsView.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 1/6/18.
//  Copyright © 2018 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnRecenterButtonsDelegate{
    func recenterButtonClicked()
    func newCenterButtonClicked()
}

class RecenterButtonsView: UIView {

    var recenterButton:UIButton?
    var newDefaultLocationButton:UIButton?
    
    var delegate:ReturnRecenterButtonsDelegate?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawRecenterAndNewDefaultLocationButtons()
    }
    
    
    
    // this will be a rectangle that is taller than it is wide //
    func drawRecenterAndNewDefaultLocationButtons(){
        recenterButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2))
        recenterButton?.setImage(UIImage(named: "RecenterIcon"), for: UIControlState.normal)
        recenterButton?.addTarget(self, action: #selector(recenterButtonOnClick), for: UIControlEvents.touchUpInside)
        recenterButton?.layer.borderColor = UIColor.white.cgColor
        recenterButton?.layer.borderWidth = 1.0
        
        newDefaultLocationButton = UIButton(frame: CGRect(x: 0, y: (self.recenterButton?.frame.origin.y)! + (self.recenterButton?.frame.size.height)!, width: self.frame.size.width, height: self.frame.size.height / 2 ))
        newDefaultLocationButton?.setImage(UIImage(named: "NewCenterIcon"), for: UIControlState.normal)
        newDefaultLocationButton?.addTarget(self, action: #selector(newCenterButtonOnClick), for: UIControlEvents.touchUpInside)
        newDefaultLocationButton?.layer.borderColor = UIColor.white.cgColor
        newDefaultLocationButton?.layer.borderWidth = 1.0
        
        self.addSubview(recenterButton!)
        self.addSubview(newDefaultLocationButton!)
    }
    
    @objc func recenterButtonOnClick(){
        self.delegate?.recenterButtonClicked()
    }
    
    @objc func newCenterButtonOnClick(){
        self.delegate?.newCenterButtonClicked()
    }
    

}
