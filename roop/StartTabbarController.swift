//
//  StartTabbarController.swift
//  roop
//
//  Created by 이천지 on 2016. 11. 12..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

class StartTabbarController: UITabBarController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.tabBar.frame.size.height = 40;
        self.tabBar.frame.origin.y = self.view.frame.size.height - 40;
        //removeTabbarItemsText()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
   
    func removeTabbarItemsText() {
        if let items = tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsetsMake(6, 6, 6, 6);
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
