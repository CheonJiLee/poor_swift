//
//  AppDelegate.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 13..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Alamofire
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var databasePath = NSString()
    var tokenStatus: Bool! = false
     
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor.black
        pageController.backgroundColor = UIColor.white
        
        
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
            findDB()
        }
        
        
        window?.rootViewController = initialViewController()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    var emailPasswordDic : Dictionary<String, String> = ["email":"","password":""]
    var newToken: String = ""
    func findDB(){
        
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            // 검색 SQL을 작성할때도 textfield의 text를 바로 입력하게 되면 "Optional('')"와 같은 문자열이 text문자열을 감싸게 되므로 뒤에 !을 붙여 옵셔널이 되지 않도록 한다.
            let querySQL = "SELECT token, email, password FROM CONTACTS"
            print("[Find from DB] SQL to find => \(querySQL)")
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            if results?.next() == true {
                let tokens = results?.string(forColumn: "token")
                let emails = results?.string(forColumn: "email")
                let passwords = results?.string(forColumn: "password")
                print("\(tokens)")
                print("\(emails)")
                print("\(passwords)")
                emailPasswordDic["email"] = emails
                emailPasswordDic["password"] = passwords
                Alamofire.request("http://www.roop.xyz/auth/local/", method: .post, parameters: emailPasswordDic).responseJSON{
                    response in
                    
                    let result = response.result.value
                    let JSON = result as! NSDictionary
                    self.newToken = JSON["token"]! as! String
                    self.updateLocalCount()
                }
                tokenStatus = true
                
            }else{
                print("find fail")
            }
            contactDB?.close()
        }else{
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
    }
    
    func updateLocalCount() {
        let email = emailPasswordDic["email"]!
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            do {
                try contactDB?.executeUpdate("UPDATE CONTACTS SET token=? WHERE email=?", values: ["\(self.newToken)","\(email)"])
            } catch {
                print(error)
            }
            contactDB?.close()
        } else {
            print("[7] Error: \(contactDB?.lastErrorMessage())")
        }

    }
    
    
    
    private func initialViewController() -> UIViewController {
        if tokenStatus! {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tokenExist")
            
            
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nonToken")
            
            
        }
    }
    
    

}

