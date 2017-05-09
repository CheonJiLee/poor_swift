//
//  ContentViewController.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 13..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    

//    @IBOutlet weak var ImageView: UIImageView!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    @IBOutlet var contentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        contentImageView.image = UIImage(named: self.imageFile)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
