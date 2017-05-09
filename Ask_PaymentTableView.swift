//
//  Ask_PaymentTableView.swift
//  roop
//
//  Created by 이천지 on 2016. 11. 4..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire

class Ask_PaymentTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var Ask_PaymentTableView: UITableView!
    
    var cardArr = Array<CardViewData>()
    var getToken:String = ""
    var cache:NSCache<AnyObject, AnyObject>!
    
    //데이터베이스 경로 설정변수 초기화
    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.SetBackBarButtonCustom()
        self.tabBarController?.tabBar.isHidden = true
        
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
                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS ( ID INTEGER PRIMARY KEY AUTOINCREMENT, TOKEN TEXT, EMAIL TEXT, PASSWORD TEXT)"
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
        self.loadCardView()
        
        self.cache = NSCache()
        Ask_PaymentTableView.tableFooterView = UIView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadCardView(){
        Alamofire.request("http://www.roop.xyz/api/look/getAsk?access_token=\(self.getToken)", method: .post).responseJSON{ response in
            print("++++++++++++++++++++ask-ask++++++=")
            
            if let JSON = response.result.value as! [AnyObject]! {
                print(JSON)
                var cardView : CardViewData
                for i in 0..<JSON.count {
                    cardView = CardViewData()
                    cardView.ansStatus = JSON[i]["__v"]! as? Int
                    cardView.cardPhotoAddress = JSON[i]["image"]! as? String
                    cardView.description = JSON[i]["description"]! as? String
                    cardView.profilePhotoAddress = JSON[i]["userGravatar"]! as? String
                    cardView.userName = JSON[i]["userName"]! as? String
                    cardView.email = JSON[i]["email"]! as? String
                    cardView.pixel = JSON[i]["pixel"] as? NSDictionary
                    cardView.userSize = JSON[i]["size"]! as? String
                    cardView.userColor = JSON[i]["color"]! as? String
                    cardView.userGender = JSON[i]["gender"]! as? String
                    
                    cardView.ansBrandname = JSON[i]["ansBrandname"] as? String
                    cardView.ansColor = JSON[i]["ansColor"] as? String
                    cardView.ansDescription = JSON[i]["ansDescription"] as? String
                    cardView.ansLink = JSON[i]["ansLink"] as? String
                    cardView.ansPrice = JSON[i]["ansPrice"] as? Int
                    cardView.ansSex = JSON[i]["ansSex"] as? String
                    cardView.ansSize = JSON[i]["ansSize"] as? String
                    self.cardArr.append(cardView)
                }
                self.Ask_PaymentTableView.reloadData()
            } else if let error = response.result.error {
                print("Error: \(error)")
                // Notify user of the error in the appropriate way
            }

        }
        
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    }
    
    func findDB(){
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            // 검색 SQL을 작성할때도 textfield의 text를 바로 입력하게 되면 "Optional('')"와 같은 문자열이 text문자열을 감싸게 되므로 뒤에 !을 붙여 옵셔널이 되지 않도록 한다.
            let querySQL = "SELECT token FROM CONTACTS"
            print("[Find from DB] SQL to find => \(querySQL)")
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            if results?.next() == true {
                let token = results?.string(forColumn: "token")
                self.getToken = token!
                print("+++++++++gettoken++++")
                print(self.getToken)
            }else{
                print("find fail")
            }
            contactDB?.close()
        }else{
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
    }
    var selectIndex = -1
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        self.performSegue(withIdentifier: "Ask_result", sender: self)

    }
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "Ask_result"){
            let destination = segue.destination as! Ask_ParentViewController
            destination.passDataInfo = self.cardArr[selectIndex]
        }
    }
    
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
        let fileURL = documentsURL.appendingPathComponent("image.png")
        
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cardArr.count > 0 {
            return cardArr.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Ask_PaymentCell", for: indexPath) as! Ask_PaymentTableViewCell
        cell.photo.image = UIImage(named: "placeholder")
        
        if (self.cache.object(forKey: cardArr[indexPath.row].cardPhotoAddress! as AnyObject) != nil){
            // 2
            // Use cache
            print("Cached image used, no need to download it")
            cell.photo.image = self.cache.object(forKey: cardArr[indexPath.row].cardPhotoAddress! as AnyObject) as? UIImage
        }else{
            
            Alamofire.download("http://www.roop.xyz\(cardArr[indexPath.row].cardPhotoAddress!)", to:
                destination).responseData { response in
                    //debugPrint(response)
                    
                    if let data = response.result.value {
                        
                        let image = UIImage(data: data)
                        cell.photo.image = image
                        self.cache.setObject(image!, forKey: self.cardArr[indexPath.row].cardPhotoAddress! as AnyObject)
                    } else {
                        print("Data was invalid")
                    }
            }
        }
        print("::::::::::::::::::::::::::::::")
        print("\(self.cardArr[indexPath.row].ansStatus!)")
        print(self.cardArr[indexPath.row].description!)
        print(self.cardArr[indexPath.row].cardPhotoAddress!)
        if(self.cardArr[indexPath.row].ansStatus! == 0){
            cell.setResult.text = "Searching"
        }else if(self.cardArr[indexPath.row].ansStatus! == 1){
            cell.setResult.text = "Completed"
        }else{
            print("error answer status")
        }
        
        cell.subscription.text = self.cardArr[indexPath.row].description!
        
        return cell
    }
 

}
