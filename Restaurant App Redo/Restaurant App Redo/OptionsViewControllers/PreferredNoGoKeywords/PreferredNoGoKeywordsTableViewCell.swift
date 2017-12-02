//
//  PreferredNoGoKeywordsTableViewCell.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 11/4/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

class PreferredNoGoKeywordsTableViewCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var ratingLabe: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
