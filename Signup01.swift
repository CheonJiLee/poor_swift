//
//  Signup01.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 13..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire

class Signup01: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var inputEmailTextfield: UITextField!
    
    @IBOutlet var inputPasswordTextfield: UITextField!
    
    @IBOutlet var hideShowBtn: UIButton!
    @IBOutlet var nextNaviBtn: UIBarButtonItem!
    @IBOutlet weak var warningEmailText: UILabel!
    @IBOutlet weak var warningPasswordText: UILabel!
    
    var hideShowBtnStatus: Bool!
    var nextPWStatus: Bool!
    var nextEmailStatus: Bool!
    var emailDupStatus: Bool! = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetBackBarButtonCustom()
        self.navigationItem.rightBarButtonItem = nil
        inputEmailTextfield.delegate = self
        inputPasswordTextfield.delegate = self
        hideShowBtnStatus = true
        nextPWStatus = false
        nextEmailStatus = false
        
        warningEmailText.isHidden = true
        warningPasswordText.isHidden = true
    }
    
    @IBAction func hideShowBtnClick(_ sender: AnyObject) {
        if(hideShowBtnStatus == true){
            hideShowBtn.setTitle("Hide", for: UIControlState())
            inputPasswordTextfield.isSecureTextEntry = false
            hideShowBtnStatus = false
        }else{
            hideShowBtn.setTitle("Show", for: UIControlState())
            inputPasswordTextfield.isSecureTextEntry = true
            hideShowBtnStatus = true
        }
        
    }
    
    //email validation check
    func validateEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.(com|org|net|int|edu|gov|mil)"
        let resultBool = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
        if(resultBool){
            self.warningEmailText.isHidden = true
        }else{
            self.warningEmailText.isHidden = false
            self.warningEmailText.text = "잘못된 이메일 주소 형식입니다."
        }
        return resultBool
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
        emailDuplicateCheck()
        nextBtnHidden()
        return true
    }

    //키보드 처리
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        emailDuplicateCheck()
        nextBtnHidden()
    }
    
    var emailCheck : Dictionary<String, String> = ["email":""]
    func emailDuplicateCheck(){
        emailCheck["email"] = inputEmailTextfield.text!
        Alamofire.request("http://www.roop.xyz/api/users/app/isEmailValid", method: .post, parameters: emailCheck)
        .responseJSON{
            response in
            
            if let json = response.result.value {
                print(json)
                let usd = json as! NSDictionary
                print(usd)
                let val = usd.object(forKey: "result") as! Bool//?
                print(val)
                
                if(val){
//                    self.warningEmailText.isHidden = false
//                    self.warningEmailText.text = "사용 가능한 이메일주소입니다."
                    print("사용 가능한 이메일주소입니다.")
                    self.emailDupStatus = true
                    //self.warningEmailText.isHidden = true
                }else{
                    print("중복된 이메일 주소입니다.")
                    self.warningEmailText.isHidden = false
                    self.warningEmailText.text = "중복된 이메일 주소입니다."
                    self.emailDupStatus = false
                }
            }
            
        }
        
    }
    
    func nextBtnHidden(){
        //email textField 예외처리
       // let emaildupBool = (self.emailDupStatus)!
        if(validateEmail("\(inputEmailTextfield.text!)") && emailDupStatus!){
            nextEmailStatus = true
        }else{
            nextEmailStatus = false
        }
        //password textField 예외처리
        let text = inputPasswordTextfield.text! as NSString
        if(text.length > 5){
            self.warningPasswordText.isHidden = true
            nextPWStatus = true
        }else{
            self.warningPasswordText.isHidden = false
            self.warningPasswordText.text = "비밀번호는 최소 6자리 이상입니다."
            nextPWStatus = false
        }
        if(nextPWStatus && nextEmailStatus){
            self.navigationItem.rightBarButtonItem = self.nextNaviBtn
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! Signup02
        destination.email = inputEmailTextfield.text!
        destination.password = inputPasswordTextfield.text!
    }

}
