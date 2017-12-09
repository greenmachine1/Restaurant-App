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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "cell")
        
        self.backgroundColor = UIColor.clear
        
        mainLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width - 10, height: 30))
        mainLabel?.textColor = Colors.sharedInstance.lightBlue
        mainLabel?.adjustsFontSizeToFitWidth = true
        self.addSubview(mainLabel!)
        
        distanceLabel = UILabel(frame: CGRect(x: 10, y: (self.mainLabel?.frame.origin.y)! + (self.mainLabel?.frame.size.height)!, width: 100, height: 30))
        distanceLabel?.textColor = Colors.sharedInstance.lightBlue
        distanceLabel?.adjustsFontSizeToFitWidth = true
        self.addSubview(distanceLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
