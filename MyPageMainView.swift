//
//  MyPageMainView.swift
//  roop
//
//  Created by 이천지 on 2016. 11. 4..
//  Copyright © 2016년 project. All rights reserved.
//
import UIKit
import Alamofire

class MyPageMainView: UIViewController {
    
    
    @IBOutlet weak var mypageProfileImage: UIImageView!
    @IBOutlet weak var mypageUserName: UILabel!
    
    @IBOutlet weak var mypageUserEmail: UILabel!
    
    //데이터베이스 경로 설정변수 초기화
    var databasePath = NSString()
    var profileAddress = ""
    override func viewDidLoad() {
        let navigationBarAppear = UINavigationBar.appearance()
        navigationBarAppear.barTintColor = UIColor.white
        // get rid of black bar underneath navbar
        navigationBarAppear.shadowImage = UIImage()
        navigationBarAppear.setBackgroundImage(UIImage(), for: .default)
        navigationController?.hidesBarsOnSwipe = true
        //staus와 옆쪽채우기 위해서 하는 작업
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.hidesBarsOnSwipe = false
        
        
        
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
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.rgb(250, green: 202, blue: 57)
        self.tabBarController?.tabBar.isHidden = false
        //staus와 옆쪽채우기 위해서 하는 작업
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        
        let radius = self.mypageProfileImage.frame.height / 2
        self.mypageProfileImage.layer.cornerRadius = radius
        self.mypageProfileImage.layer.masksToBounds = true
    }
    
    @IBAction func roopingBtnClick(_ sender: Any) {
    }
    
    @IBAction func askBtnClick(_ sender: Any) {
    }
    
    @IBAction func paymentBtnClick(_ sender: Any) {
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
            let querySQL = "SELECT email, name, gravatar FROM CONTACTS"
            print("[Find from DB] SQL to find => \(querySQL)")
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            if results?.next() == true {
                
                let email = results?.string(forColumn: "email")
                let name = results?.string(forColumn: "name")
                let gravatar = results?.string(forColumn: "gravatar")
                print("\(email)")
                print("\(name)")
                print("\(gravatar)")
                mypageUserEmail.text = email!
                mypageUserName.text = name!
                profileAddress = gravatar!
                Alamofire.download("https:\(profileAddress)", to:
                    destination).responseData { response in
                        //debugPrint(response)
                        if let data = response.result.value {
                            let image = UIImage(data: data)
                            
                            self.mypageProfileImage.image = image!
                        } else {
                            print("Data was invalid")
                        }
                }
                
            }else{
                print("find fail")
            }
            contactDB?.close()
        }else{
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
    }


}
