//
//  CameraCollectionViewCell.swift
//  roop
//
//  Created by 이천지 on 2016. 12. 12..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit


class CameraCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbNail: UIImageView!
    
    func setThumbnailImage(thumbNailImage: UIImage) {
        self.thumbNail.image = thumbNailImage
    }
    
}
