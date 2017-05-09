//
//  HomeCollectionViewCell.swift
//  roop
//
//  Created by 이천지 on 2016. 10. 31..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate2 {
    func cellTapped(_ cell: HomeCollectionViewCell)
}

class HomeCollectionViewCell: UICollectionViewCell  {
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    
    @IBOutlet weak var roopingIcon_off: UIImageView!
    @IBOutlet weak var roopingIcon_on: UIImageView!
    
    var likeStatus:Bool = false
    var buttonDelegate2: ButtonCellDelegate2?
    @IBAction func setLikeBtnAction(_ sender: Any) {
        if let delegate = buttonDelegate2 {
            delegate.cellTapped(self)
        }
        if(!likeStatus){
            likeStatus = true
            print("=======11111111=========")
        }else{
            likeStatus = false
            print("=======0000000000=========")
        }
    }
    
}
