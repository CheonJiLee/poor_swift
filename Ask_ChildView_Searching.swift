//
//  Ask_ParentViewController.swift
//  roop
//
//  Created by 이천지 on 2016. 12. 23..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class Ask_ChildView_Searching: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var userSize: UILabel!
    @IBOutlet weak var userColor: UILabel!
    @IBOutlet weak var userGender: UILabel!
    @IBOutlet weak var photoConstraints: NSLayoutConstraint!
    
    var passDataInfo = CardViewData()
    
    override func viewDidLoad() {
        
        let pixelHeight = (self.passDataInfo.pixel?["h"] as! NSString).integerValue
        let pixelWidth = (self.passDataInfo.pixel?["w"] as! NSString).integerValue
        print("===================")
        print(pixelHeight)
        print(pixelWidth)
        
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
        
        if(passDataInfo.description != nil){
            userDescription.text = passDataInfo.description
        }
        if(passDataInfo.userSize != nil){
            userSize.text = passDataInfo.userSize
        }
        if(passDataInfo.userColor != nil){
            userColor.text = passDataInfo.userColor
        }
        if(passDataInfo.userGender != nil){
            userGender.text = passDataInfo.userGender
        }
    }
    
   }







