//
//  Ask_ParentViewController.swift
//  roop
//
//  Created by 이천지 on 2016. 12. 23..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

class Ask_ParentViewController: UIViewController {
    
    @IBOutlet weak var searchingContainerView: UIView!
    @IBOutlet weak var completedContainerView: UIView!
    var passDataInfo = CardViewData()
    
    override func viewDidLoad() {
        let Ask_status = self.passDataInfo.ansStatus
        
        if(Ask_status == 0){
            completedContainerView.isHidden = true
        }else if(Ask_status == 1){
            searchingContainerView.isHidden = true
        }else{
            print("no Ask resultView")
        }
        self.SetBackBarButtonCustom()
    }
    
    func SetBackBarButtonCustom()
    {
        //Initialising "back button"
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "backButton"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.onClickBack), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33/2, height: 50/2)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
    }
    func onClickBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Ask_Completed") {
            let completed_VC = segue.destination as! Ask_ChildView_Completed
            completed_VC.passDataInfo = passDataInfo
        }else if(segue.identifier == "Ask_Searching"){
            let completed_VC = segue.destination as! Ask_ChildView_Searching
            completed_VC.passDataInfo = passDataInfo
        }
    }
}
