//
//  WorkingView.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 1/18/18.
//  Copyright © 2018 Cory Green. All rights reserved.
//

import UIKit

@objc protocol WorkingViewDelegate{
    func isDoneSpinning()
}


// this will be a view within a view letting the user know that it is working on loading info //
class WorkingView: UIView {
    
    var activityIndicatorView:UIActivityIndicatorView?
    var working:UIView?
    var workingLabel:UILabel?
    var delegate:WorkingViewDelegate?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    
    func drawWorkingView(){
        
        working = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width / 2, height: self.frame.size.width / 2))
        working!.center = self.center
        working!.layer.cornerRadius = working!.frame.size.width / 2
        working!.clipsToBounds = true
        working!.backgroundColor = UIColor.black
        working!.layer.borderColor = Colors.sharedInstance.lightBlue.cgColor
        working!.layer.borderWidth = 10.0
        
        self.addSubview(working!)
        
        workingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: working!.frame.size.width - 10, height: 30))
        workingLabel!.center = working!.center
        workingLabel!.center.y = working!.center.y + 20
        workingLabel!.text = "Working..."
        workingLabel!.textColor = Colors.sharedInstance.lightBlue
        workingLabel!.textAlignment = .center
        
        self.addSubview(workingLabel!)
        
        
        activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicatorView?.center = working!.center
        activityIndicatorView?.center.y = workingLabel!.center.y - 50
        self.addSubview(activityIndicatorView!)
        self.startActivitySpinner()
        
    }

    func startActivitySpinner(){
        self.activityIndicatorView?.startAnimating()
    }
    
    
    // animates the center activity circle to scale in on itself //
    func stopActivitySpinner(){
        UIView.animate(withDuration: 0.50, animations: {
            
            self.working?.frame.size.height = 0
            self.working?.frame.size.width = 0
            self.working?.layer.cornerRadius = (self.working?.frame.size.width)! / 2
            self.working?.layer.borderWidth = 0
            self.working?.center = self.center
            
            self.workingLabel?.removeFromSuperview()
            self.activityIndicatorView?.removeFromSuperview()

        }) { (complete) in
            self.activityIndicatorView?.stopAnimating()
            self.delegate?.isDoneSpinning()
        }
    }
    
}
