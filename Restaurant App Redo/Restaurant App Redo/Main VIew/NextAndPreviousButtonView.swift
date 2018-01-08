//
//  NextAndPreviousButtonView.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 12/25/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnButtonPressedDelegate{
    func returnButtonPressed(trueForNextFalseForPrevious:Bool)
    func nextButtonAndPreviousButtonsAreOut(bothOut:Bool)
}

class NextAndPreviousButtonView: UIView {
    
    var nextButton:UIButton?
    var previousButton:UIButton?
    var previousButtonIsOut = false

    var delegate:ReturnButtonPressedDelegate?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = UIColor.blue
        self.createNextButtonWithPreviousButtonHidden()
    }
    
    // creates the next button full width //
    func createNextButtonWithPreviousButtonHidden(){
        nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        nextButton?.backgroundColor = Colors.sharedInstance.lightGreen
        nextButton?.setTitle("Go!", for: UIControlState.normal)
        nextButton?.setTitleColor(UIColor.black, for: UIControlState.highlighted)
        nextButton?.addTarget(self, action: #selector(self.nextButtonOnClick), for: UIControlEvents.touchUpInside)
        self.addSubview(nextButton!)
        
        // the previous button shall remain hidden until the next button is clicked //
        previousButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: self.frame.size.height))
        previousButton?.backgroundColor = Colors.sharedInstance.lightBlue
        previousButton?.setTitle("Previous", for: UIControlState.normal)
        previousButton?.setTitleColor(UIColor.black, for: UIControlState.highlighted)
        previousButton?.addTarget(self, action: #selector(self.previousButtonOnClick), for: UIControlEvents.touchUpInside)
        self.addSubview(previousButton!)
        
        self.previousButtonIsOut = false
        self.delegate?.nextButtonAndPreviousButtonsAreOut(bothOut: false)
    }
    
    func slideNextButtonBackToFullLength(){
        if(nextButton != nil && previousButton != nil){
            if(self.previousButtonIsOut == true){
                UIView.animate(withDuration: 0.5, animations: {
                    self.nextButton?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                    self.previousButton?.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.size.height)
                    self.previousButtonIsOut = false
                    self.delegate?.nextButtonAndPreviousButtonsAreOut(bothOut: false)
                })
            }
        }
    }
    
    
    // pushes the next button to the center and reveals the previous button //
    func makeNextAndPreviousButtonsHalfWidth(){
        if(previousButtonIsOut == false){
            if(nextButton != nil && previousButton != nil){
                UIView.animate(withDuration: 0.5, animations: {
                    self.nextButton?.frame = CGRect(x: self.frame.size.width / 2, y: 0, width: self.frame.size.width / 2, height: 70)
                    self.previousButton?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width / 2, height: 70)
                    self.previousButtonIsOut = true
                    self.delegate?.nextButtonAndPreviousButtonsAreOut(bothOut: true)
                })
            }
        }
    }
    
    func updateNextButtonTitle(title:String){
        self.nextButton?.setTitle(title, for: UIControlState.normal)
    }
    
    @objc func nextButtonOnClick(){
        self.delegate?.returnButtonPressed(trueForNextFalseForPrevious: true)
    }
    
    @objc func previousButtonOnClick(){
        self.delegate?.returnButtonPressed(trueForNextFalseForPrevious: false)
    }

}
