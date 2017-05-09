//
//  Signup03.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 13..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

class Signup03: UIViewController {
    //넘겨온 값
    var name = ""
    var email = ""
    var password = ""
    
    var dateString = ""
    @IBOutlet var selectDate: UIButton!
    
    @IBOutlet var selectDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetBackBarButtonCustom()
        selectDatePicker?.isHidden = true
        selectDatePicker.datePickerMode = UIDatePickerMode.date
    }
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! Signup04
        destination.email = self.email
        destination.password = self.password
        destination.name = self.name
        destination.date = self.dateString
    }
    
    //date Picker controller
    @IBAction func selectDateClick(_ sender: AnyObject) {
        selectDatePicker?.isHidden = false
    }
    
    @IBAction func selectDatePickerVal(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.dateString = dateFormatter.string(from: selectDatePicker.date)
        selectDate.setTitle(dateString, for: UIControlState())
        print("\(dateString)")
    }
    
    //navi var back button controller
    func SetBackBarButtonCustom()
    {
        //Initialising "back button"
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "backButton"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(Signup01.onClickBack), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33/2, height: 50/2)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func onClickBack()
    {
        self.navigationController?.popViewController(animated: true)
    }


}
