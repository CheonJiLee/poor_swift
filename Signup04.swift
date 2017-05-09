//
//  Signup04.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 13..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire
class Signup04: UIViewController {
    //넘겨온 값
    var email = ""
    var password = ""
    var name = ""
    var date = ""
    
    var sendSignInfo : Dictionary<String, String> = [:]
    @IBOutlet var onFemaleStatus: UIImageView!
    @IBOutlet var onMaleStatus: UIImageView!
    
    
    var databasePath = NSString()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetBackBarButtonCustom()
        onFemaleStatus?.isHidden = true
        onMaleStatus?.isHidden = true
        sendSignInfo["email"] = email
        sendSignInfo["password"] = password
        sendSignInfo["name"] = name
        sendSignInfo["date"] = date
        
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
    @IBAction func femaleBtnClick(_ sender: AnyObject) {
        onFemaleStatus?.isHidden = false
        onMaleStatus?.isHidden = true
    }
    
    @IBAction func maleBtnClick(_ sender: AnyObject) {
        onFemaleStatus?.isHidden = true
        onMaleStatus?.isHidden = false
    }
    
    @IBAction func DoneBtnClick(_ sender: AnyObject) {
        if(onFemaleStatus?.isHidden == true){
            sendSignInfo["gender"] = "Male"
        }else{
            sendSignInfo["gender"] = "Female"
        }
        print("\(sendSignInfo)")
        print("여기까지 됩니다.")
        //여기서 데이터값을 서버로 보내면 됨
        
        Alamofire.request("http://www.roop.xyz/api/users/", method: .post, parameters: sendSignInfo).responseJSON{
            response in
            print("=========response=======")
            print(response)
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                print("========JSON=============")
                print(JSON)
                let responseToken = JSON["token"]! as! String
                let responseName = JSON["name"]! as! String
                let responseGravatar = JSON["gravatar"]! as! String
                print("========responseToken=============")
                print("\(responseToken)")
                
                let contactDB = FMDatabase(path: self.databasePath as String)
                if (contactDB?.open())! {
                    print("[Save to DB] token : \(responseToken), email : \(self.email), password : \(self.password) ")
                    // SQL에 데이터를 입력하기 전 바로 입력하게 되면 "Optional('')"와 같은 문자열이 text문자열을 감싸게 되므로 뒤에 !을 붙여 옵셔널이 되지 않도록 한다.
                    let insertSQL = "INSERT INTO CONTACTS (token, email, password, name, gravatar) VALUES ('\(responseToken)', '\(self.email)','\(self.password)', '\(responseName)', '\(responseGravatar)')"
                    print("[Save to DB] SQL to Insert => \(insertSQL)")
                    let result = contactDB?.executeUpdate(insertSQL, withArgumentsIn: nil)
                    print("=========result======")
                    print("\(result)")
                    if !result! {
                        print("[4] Error : \(contactDB?.lastErrorMessage())")
                    }else{
                        print("Contact Added")
                        let querySQL = "SELECT token, email, password, name, gravatar FROM CONTACTS"
                        print("[Find from DB] SQL to find => \(querySQL)")
                        let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
                        if results?.next() == true {
                            let tokens = results?.string(forColumn: "token")
                            let emails = results?.string(forColumn: "email")
                            let passwords = results?.string(forColumn: "password")
                            let gravatar = results?.string(forColumn: "gravatar")
                            print("\(tokens)")
                            print("\(emails)")
                            print("\(passwords)")
                            print("\(gravatar)")
                        }else{
                            print("find fail")
                        }
                        contactDB?.close()
                    }
                }else{
                    print("[5] Error : \(contactDB?.lastErrorMessage())")
                }
            }
        }
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
