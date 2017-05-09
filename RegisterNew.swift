//
//  RegisterNew.swift
//  roop
//
//  Created by 이천지 on 2016. 10. 9..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire

class RegisterNew: UIViewController{
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet weak var femaleCheckImage: UIImageView!
    @IBOutlet weak var maleCheckImage: UIImageView!
    
    @IBOutlet weak var desciptionTextField: UITextField!
    
    @IBOutlet weak var sizeTextField: UITextField!
    
    @IBOutlet weak var colorTextField: UITextField!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userEmailLabel: UILabel!
    
    var selectGender:String = ""
    var getToken:String = ""
    var setImage = UIImage()
    var tempProfile:String = ""
    
    //데이터베이스 경로 설정변수 초기화
    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        femaleCheckImage.isHidden = true
        maleCheckImage.isHidden = true
        
        imageView.image = setImage
        
        let radius = profileImageView.frame.size.height / 2
        profileImageView.layer.cornerRadius = radius
        profileImageView.layer.masksToBounds = true
        
        
        self.SetBackBarButtonCustom()
        
        
        
        
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
        findDB()
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
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

    
    //navi var back button controller
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
    
    @IBAction func femaleCheckBtnClick(_ sender: AnyObject) {
        femaleCheckImage.isHidden = false
        maleCheckImage.isHidden = true
        selectGender = "female"
    }
    
    
    @IBAction func maleCheckBtnClick(_ sender: AnyObject) {
        femaleCheckImage.isHidden = true
        maleCheckImage.isHidden = false
        selectGender = "male"
    }
    
    
    
    @IBAction func unwindAfterAsk(_ sender: AnyObject) {
        
        self.Registerform()
        
        self.performSegue(withIdentifier: "unwindAfterAsk", sender: self)
        print("카카카카")
    }
    
    func Registerform(){
        let imageData = UIImagePNGRepresentation(self.imageView.image!)!
        
//        let parameters = [
//            "description" : self.desciptionTextField.text!,
//            "size" : self.sizeTextField.text!,
//            "color" : self.colorTextField.text!,
//            "gender" : self.selectGender
//        ]
//        print("======imagedata==========")
//        print("\(imageData)")
//        print(self.desciptionTextField.text!.data(using: String.Encoding.utf8)!)
//        print(self.sizeTextField.text!.data(using: String.Encoding.utf8)!)
//        print(self.colorTextField.text!.data(using: String.Encoding.utf8)!)
//        print(self.selectGender.data(using: String.Encoding.utf8)!)
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                    
                multipartFormData.append(imageData, withName: "file", fileName: "roopImage.png", mimeType: "image/png")
                //for (key, value) in parameters {
                //    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                //}
                multipartFormData.append(self.desciptionTextField.text!.data(using: String.Encoding.utf8)!, withName: "description")
                multipartFormData.append(self.sizeTextField.text!.data(using: String.Encoding.utf8)!, withName: "size")
                multipartFormData.append(self.colorTextField.text!.data(using: String.Encoding.utf8)!, withName: "color")
                multipartFormData.append(self.selectGender.data(using: String.Encoding.utf8)!, withName: "gender")
            },
            to: "http://www.roop.xyz/api/look/upload?access_token=\(getToken)",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
        
    }
    
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
        let fileURL = documentsURL.appendingPathComponent("image.png")
        
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories]) }
    
    func findDB(){
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            // 검색 SQL을 작성할때도 textfield의 text를 바로 입력하게 되면 "Optional('')"와 같은 문자열이 text문자열을 감싸게 되므로 뒤에 !을 붙여 옵셔널이 되지 않도록 한다.
            let querySQL = "SELECT email, name, gravatar, token FROM CONTACTS"
            print("[Find from DB] SQL to find => \(querySQL)")
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            if results?.next() == true {
                let email = results?.string(forColumn: "email")
                let name = results?.string(forColumn: "name")
                let gravatar = results?.string(forColumn: "gravatar")
                let token = results?.string(forColumn: "token")
                print("\(email)")
                print("\(name)")
                print("\(gravatar)")
                userEmailLabel.text = email!
                userNameLabel.text = name!
                Alamofire.download("https:\(gravatar!)", to:
                    destination).responseData { response in
                        //debugPrint(response)
                        if let data = response.result.value {
                            let image = UIImage(data: data)
                            
                            self.profileImageView.image = image!
                        } else {
                            print("Data was invalid")
                        }
                }

                
                
                
                
                self.getToken = token!
            }else{
                print("find fail")
            }
            contactDB?.close()
        }else{
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
    }

}
