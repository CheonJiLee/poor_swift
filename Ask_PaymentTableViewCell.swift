//
//  Ask_PaymentTableViewCell.swift
//  roop
//
//  Created by 이천지 on 2016. 11. 4..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit


class Ask_PaymentTableViewCell: UITableViewCell{
    @IBOutlet var photo: UIImageView!
    @IBOutlet var setResult: UILabel!
    
    @IBOutlet var subscription: UILabel!
        
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
