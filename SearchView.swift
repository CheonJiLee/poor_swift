//
//  SearchView.swift
//  roop
//
//  Created by 이천지 on 2016. 11. 15..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire

class SearchView : UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    
    var getToken:String = ""
    
    //데이터베이스 경로 설정변수 초기화
    var databasePath = NSString()
   
    @IBOutlet weak var searchViewTableView: UITableView!
    
    override func viewDidLoad() {
        let navigationBarAppear = UINavigationBar.appearance()
        navigationBarAppear.barTintColor = UIColor.white
        // get rid of black bar underneath navbar
        navigationBarAppear.shadowImage = UIImage()
        navigationBarAppear.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.isTranslucent = false
        self.getKeyword()
        searchViewTableView.tableFooterView = UIView()
        searchViewTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged )
        
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
    
    func textFieldDidChange(textField: UITextField) {
        let parameters: Parameters = [
            "keyword": "\(textField.text!)",
        ]
        
        Alamofire.request("http://www.roop.xyz/api/look/getKeyword", method: .post, parameters: parameters).responseJSON { response in
//            print(response)
            do {
                self.keywordArr = []
                let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! [String:AnyObject]
                let getSearchKeyword = parsedData["keywords"]! as! [AnyObject]
                
                if getSearchKeyword.count > 0{
                    print("==========count=======")
                    print(getSearchKeyword.count)
                    for i in 0..<getSearchKeyword.count {
                        print(getSearchKeyword)
                        let keyword = getSearchKeyword[i] as! [String:AnyObject]
                        print(keyword["name"] as! String)
                        self.keywordArr.append(keyword["name"] as! String)
                    }
                }else{
                    self.keywordArr.append("찾으시는 검색어가 없습니다.")
                }
                self.searchViewTableView.reloadData()
            } catch let error as NSError {
                print(error)
            }


        }
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        //staus와 옆쪽채우기 위해서 하는 작업
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
    }
    var keywordArr = [String]()
    
    func getKeyword(){
        let parameters: Parameters = [
            "keyword": ""
        ]
        Alamofire.request("http://www.roop.xyz/api/look/getKeyword", method: .post, parameters: parameters).responseJSON { response in

            do {
                
                let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! [String:AnyObject]
                let getSearchKeyword = parsedData["keywords"]! as! [AnyObject]
                print(getSearchKeyword)
                if getSearchKeyword.count > 0{
                    for i in 0..<getSearchKeyword.count {
                        print(getSearchKeyword)
                        let keyword = getSearchKeyword[i] as! [String:AnyObject]
                        self.keywordArr.append(keyword["name"] as! String)
                    }
                }
                self.searchViewTableView.reloadData()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    var selectIndex = -1
    var passKeyword = ""
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        self.passKeyword = self.keywordArr[indexPath.row]
        self.performSegue(withIdentifier: "search_result", sender: self)
        
    }
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "search_result"){
            let destination = segue.destination as! SearchResultViewController
            destination.keyword  = self.passKeyword
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.keywordArr.count > 0 {
            return self.keywordArr.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchView_Cell", for: indexPath) as! SearchViewTableViewCell
        cell.keyword.text = self.keywordArr[indexPath.row]
        return cell
    }
    func findDB(){
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            // 검색 SQL을 작성할때도 textfield의 text를 바로 입력하게 되면 "Optional('')"와 같은 문자열이 text문자열을 감싸게 되므로 뒤에 !을 붙여 옵셔널이 되지 않도록 한다.
            let querySQL = "SELECT email, name, gravatar, token FROM CONTACTS"
            print("[Find from DB] SQL to find => \(querySQL)")
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            if results?.next() == true {
                let token = results?.string(forColumn: "token")
                
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
