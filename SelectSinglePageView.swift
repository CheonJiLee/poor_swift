//
//  SelectSinglePageView.swift
//  roop
//
//  Created by 이천지 on 2016. 11. 10..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
class SelectSinglePageView: UIViewController {
    
    var passDataInfo = CardViewData()
    var photoImage = UIImage()
    var profileImage = UIImage()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var singlePhoto: UIImageView!
    @IBOutlet weak var singleProfile: UIImageView!
    @IBOutlet weak var singleUserName: UILabel!
    @IBOutlet weak var singleEmail: UILabel!
    @IBOutlet weak var ansBrandName: UILabel!
    @IBOutlet weak var ansPrice: UILabel!
    @IBOutlet weak var ansDescription: UILabel!
    @IBOutlet weak var ansSize: UILabel!
    @IBOutlet weak var ansColor: UILabel!
    @IBOutlet weak var ansGender: UILabel!

    @IBOutlet weak var singPhotoConstraints: NSLayoutConstraint!
    
    var interactor:Interactor? = nil
    
    override func viewDidLoad() {
        
        let pixelHeight = (self.passDataInfo.pixel?["h"] as! NSString).integerValue
        let pixelWidth = (self.passDataInfo.pixel?["w"] as! NSString).integerValue
        print("===================")
        print(pixelHeight)
        print(pixelWidth)
        
        let radius = singleProfile.frame.size.height / 2
        singleProfile.layer.cornerRadius = radius
        singleProfile.layer.masksToBounds = true
        
        let screenSize: CGRect = UIScreen.main.bounds
        let widthRatio  = UIScreen.main.bounds.width  / CGFloat(pixelWidth)
        singPhotoConstraints.constant = CGFloat(CGFloat(pixelHeight) * widthRatio)
        print(screenSize)
        
        Alamofire.request("http://www.roop.xyz\(passDataInfo.cardPhotoAddress!)").responseImage { response in
            debugPrint(response)
            
            if let image = response.result.value {
                self.singlePhoto.image = image
            }
        }
        Alamofire.request("https:\(passDataInfo.profilePhotoAddress!)").responseImage { response in
            debugPrint(response)
            
            if let image = response.result.value {
                self.singleProfile.image = image
            }
        }
        
        
//        self.singleProfile.image = profileImage
        
        singleUserName.text = passDataInfo.userName
        singleEmail.text = passDataInfo.email!
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
//        self.SetBackBarButtonCustom()
        
        instantiatePanGestureRecognizer(self, #selector(gesture))
    }
//    
//    func SetBackBarButtonCustom()
//    {
//        //Initialising "back button"
//        let btnLeftMenu: UIButton = UIButton()
//        btnLeftMenu.setImage(UIImage(named: "backButton"), for: UIControlState())
//        btnLeftMenu.addTarget(self, action: #selector(self.onClickBack), for: UIControlEvents.touchUpInside)
//        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33/2, height: 50/2)
//        let barButton = UIBarButtonItem(customView: btnLeftMenu)
//        self.navigationItem.leftBarButtonItem = barButton
//    }
//    
//    func onClickBack()
//    {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismissVCLeftToRight(self)
    }
    
    func gesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        dismissVCOnPanGesture(self, sender, interactor!)
    }
    
    
}
