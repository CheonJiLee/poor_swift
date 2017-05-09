//
//  Signup02.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 13..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

class Signup02: UIViewController, UITextFieldDelegate {
    
    //넘겨받은 값
    var email = ""
    var password = ""
    @IBOutlet var inputNameTextField: UITextField!
    
    @IBOutlet var nextNaviBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetBackBarButtonCustom()
        inputNameTextField.delegate = self
        self.navigationItem.rightBarButtonItem = nil
    }
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! Signup03
        destination.email = self.email
        destination.password = self.password
        destination.name = inputNameTextField.text!
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
    
    //키보드 처리
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nextBtnHidden()
        return true
    }
    
    //키보드 처리
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        nextBtnHidden()
    }
    
    func nextBtnHidden(){
        //password textField 예외처리
        let text = inputNameTextField.text! as NSString
        if(text.length > 0){
            self.navigationItem.rightBarButtonItem = self.nextNaviBtn
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }

}
