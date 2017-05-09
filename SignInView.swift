//
//  SignInView.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 17..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire

class SignInView : UIViewController, UITextFieldDelegate{

    @IBOutlet var inputPasswordTextField: UITextField!
    @IBOutlet var inputEmailTextField: UITextField!
    
    @IBOutlet weak var warningEmailText: UILabel!
    @IBOutlet weak var warningPasswordText: UILabel!
    
    var loginSuccess:Bool = false
    
    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetBackBarButtonCustom()
        warningEmailText.isHidden = true
        warningPasswordText.isHidden = true
        
        // 애플리케이션이 실행되면 데이터베이스 파일이 존재하는지 체크한다. 존재하지 않으면 데이터베이스파일과 테이블을 생성한다.
        let filemgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appendingFormat("/roop.db")
        
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                // 테이블 생성처리
                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS ( ID INTEGER PRIMARY KEY AUTOINCREMENT, TOKEN TEXT, EMAIL TEXT, PASSWORD TEXT, NAME TEXT, GRAVATAR TEXT)"
                if !(contactDB?.executeStatements(sql_stmt))! {
                    print("[2] Error : \(contactDB?.lastErrorMessage())")
                }
                contactDB?.close()
            }else{
                print("[3] Error : \(contactDB?.lastErrorMessage())")
            }

        }else{
            print("[1] SQLite 파일 존재!!")
        }

    }
    
    @IBAction func logInBtnClick(_ sender: AnyObject) {
        emailPasswordConfirm()
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
        return true
    }
    
    //키보드 처리
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    var emailPasswordDic : Dictionary<String, String> = ["email":"","password":""]
    
    func emailPasswordConfirm(){
        
        emailPasswordDic["email"] = inputEmailTextField.text!
        emailPasswordDic["password"] = inputPasswordTextField.text!
        Alamofire.request("http://www.roop.xyz/auth/local/", method: .post, parameters: emailPasswordDic).responseJSON{
            response in
            
            let result = response.result.value
            let JSON = result as! NSDictionary
            print("====emailpassword confirm================")
            print(JSON)
            print("====================")
            let message = "message"
            let email = "email"
            let responseValue = JSON.allKeys.first! as! String
            if responseValue == message {
                self.warningPasswordText.isHidden = false
                self.warningPasswordText.text = JSON["message"]! as? String
                print("=============login fail====================")
            }else if responseValue == email{
            
                let responseToken = JSON["token"]! as! String
                let responseName = JSON["name"]! as! String
                let responseGravatar = JSON["gravatar"]! as! String

                //print("\(responseResult)")
                // self.createDB()
                
                let contactDB = FMDatabase(path: self.databasePath as String)
                if (contactDB?.open())! {
                    print("[Save to DB] token : \(responseToken)")
                    // SQL에 데이터를 입력하기 전 바로 입력하게 되면 "Optional('')"와 같은 문자열이 text문자열을 감싸게 되므로 뒤에 !을 붙여 옵셔널이 되지 않도록 한다.
                    let insertSQL = "INSERT INTO CONTACTS (token, email, password, name, gravatar) VALUES ('\(responseToken)', '\(self.emailPasswordDic["email"]!)', '\(self.emailPasswordDic["password"]!)', '\(responseName)', '\(responseGravatar)')"
                    print("[Save to DB] SQL to Insert => \(insertSQL)")
                    let result = contactDB?.executeUpdate(insertSQL, withArgumentsIn: nil)
                    if !result! {
                        print("[4] Error : \(contactDB?.lastErrorMessage())")
                    }else{
                        print("Contact Added")
                        let querySQL = "SELECT token, email, password, gravatar FROM CONTACTS"
                        print("[Find from DB] SQL to find => \(querySQL)")
                        let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
                        if results?.next() == true {
                            let tokens = results?.string(forColumn: "token")
                            let emails = results?.string(forColumn: "email")
                            let passwords = results?.string(forColumn: "password")
                            let gravatar = results?.string(forColumn: "gravatar")
                            print("++++++++++++++++emailconfirm save data++++++++++++=")
                            print("\(tokens)")
                            print("\(emails)")
                            print("\(passwords)")
                            print("\(gravatar)")
                            self.loginSuccess = true
                        }else{
                            print("find fail")
                        }
                        
                    }
                }else{
                    print("[5] Error : \(contactDB?.lastErrorMessage())")
                }
                contactDB?.close()
                self.performSegue(withIdentifier: "loginSuccess", sender: self)
                

            }
         }

        
    }

}

