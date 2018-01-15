//
//  ListViewTableViewCell.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/26/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

class ListViewTableViewCell: UITableViewCell {
    
    var mainLabel:UILabel?
    var ratingLabel:UILabel?
    var distanceLabel:UILabel?
    var starImage:UIImageView?
    var starImageTurnedOn:Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "cell")
        
        self.backgroundColor = UIColor.clear
        
        starImage = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        //starImage?.tintColor = Colors.sharedInstance.lightGreen
    
        self.addSubview(starImage!)
        
        mainLabel = UILabel(frame: CGRect(x: (self.starImage?.frame.origin.x)! + (self.starImage?.frame.size.width)! + 10, y: 0, width: self.frame.size.width - 10, height: 30))
        mainLabel?.textColor = Colors.sharedInstance.lightBlue
        mainLabel?.adjustsFontSizeToFitWidth = true
        //mainLabel?.backgroundColor = UIColor.blue
        self.addSubview(mainLabel!)
        
        distanceLabel = UILabel(frame: CGRect(x: (self.starImage?.frame.origin.x)! + (self.starImage?.frame.size.width)! + 10, y: (self.mainLabel?.frame.origin.y)! + (self.mainLabel?.frame.size.height)!, width: 100, height: 30))
        distanceLabel?.font = distanceLabel?.font.withSize(15)
        distanceLabel?.textColor = UIColor.white
        distanceLabel?.adjustsFontSizeToFitWidth = true
        self.addSubview(distanceLabel!)

            
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(selected == true){
            self.mainLabel?.textColor = UIColor.black
            
        }else{
            self.mainLabel?.textColor = Colors.sharedInstance.lightBlue
        }

        // Configure the view for the selected state
    }

}
