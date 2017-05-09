//
//  Ask_ChildView_Completed.swift
//  roop
//
//  Created by 이천지 on 2016. 12. 23..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class Ask_ChildView_Completed: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var ansBrandName: UILabel!
    @IBOutlet weak var ansPrice: UILabel!
    @IBOutlet weak var ansDescription: UILabel!
    @IBOutlet weak var ansSize: UILabel!
    @IBOutlet weak var ansColor: UILabel!
    @IBOutlet weak var ansGender: UILabel!
    
    @IBOutlet weak var photoConstraints: NSLayoutConstraint!
    var passDataInfo = CardViewData()
    
    override func viewDidLoad() {
        let pixelHeight = (self.passDataInfo.pixel?["h"] as! NSString).integerValue
        let pixelWidth = (self.passDataInfo.pixel?["w"] as! NSString).integerValue
        print("===================")
        print(pixelHeight)
        print(pixelWidth)
        
        ansDescription.lineBreakMode = .byWordWrapping
        ansDescription.numberOfLines = 0;
        
        let widthRatio  = UIScreen.main.bounds.width  / CGFloat(pixelWidth)
        photoConstraints.constant = CGFloat(CGFloat(pixelHeight) * widthRatio)
        
        let radius = profileImageView.frame.size.height / 2
        profileImageView.layer.cornerRadius = radius
        profileImageView.layer.masksToBounds = false
        
        Alamofire.request("http://www.roop.xyz\(passDataInfo.cardPhotoAddress!)").responseImage { response in
            debugPrint(response)
            
            if let image = response.result.value {
                self.photoImageView.image = image
            }
        }
        
        Alamofire.request("https:\(passDataInfo.profilePhotoAddress!)").responseImage { response in
            debugPrint(response)
            
            if let image = response.result.value {
                self.profileImageView.image = image
            }
        }
        
        
        userName.text = passDataInfo.userName
        userEmail.text = passDataInfo.email!
        if(passDataInfo.ansDescription != nil){
            ansDescription.text = passDataInfo.ansDescription
        }
        if(passDataInfo.ansColor != nil){
            ansColor.text = passDataInfo.ansColor
        }
        if(passDataInfo.ansPrice != nil){
            ansPrice.text = "\(passDataInfo.ansPrice!)"
        }
        if(passDataInfo.ansSize != nil){
            ansSize.text = passDataInfo.ansSize
        }
        if(passDataInfo.ansSex != nil){
            ansGender.text = passDataInfo.ansSex
        }
        if(passDataInfo.ansBrandname != nil){
            ansBrandName.text = passDataInfo.ansBrandname
        }
    }
    
   }





