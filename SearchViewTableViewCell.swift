//
//  SearchViewTableViewCell.swift
//  roop
//
//  Created by 이천지 on 2016. 12. 31..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit


class SearchViewTableViewCell: UITableViewCell{
 
    @IBOutlet weak var keyword: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
