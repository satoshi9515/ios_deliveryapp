//
//  CustomCell.swift
//  GsTodo
//
//  Created by NaokiKameyama on 2020/05/6.
//  Copyright © 2020 NaokiKameyama. All rights reserved.
//

import UIKit

/// TableViewのカスタムセル
class CustomCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
