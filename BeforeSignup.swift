//
//  BeforeSignup.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 13..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Photos

class BeforeSignup: UIViewController {
    
    @IBOutlet var backgroundImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        _ = PHAsset.fetchAssets(with: .image, options: fetchOptions) as! PHFetchResult<AnyObject>
        //첫 화면에 네비바 숨기기
//        navigationController?.navigationBarHidden = true
        //navigationController?.navigationBar.barTintColor = UIColor.init(red: 250/255, green: 202/255, blue: 57/255, alpha: 1)
        //navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
