//
//  SearchResultViewController.swift
//  roop
//
//  Created by 이천지 on 2017. 1. 2..
//  Copyright © 2017년 project. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class SearchResultViewController: UIViewController, UICollectionViewDataSource,SearchLayoutDelegate,ButtonCellDelegate4, UIViewControllerTransitioningDelegate {
    var keyword = ""
    
    @IBOutlet var collectionView: UICollectionView!
    
    var cardArr = Array<CardViewData>()
    
    var getToken:String = ""
    //데이터베이스 경로 설정변수 초기화
    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.SetBackBarButtonCustom()
        let layout = SearchLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        self.tabBarController?.tabBar.isHidden = true
        collectionView.collectionViewLayout = layout
        
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
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
//        override func viewDidLayoutSubviews() {
//            let section = 1
//            let lastItemIndex = self.collectionView.numberOfItems(inSection: section) - 1
//            let indexPath:NSIndexPath = NSIndexPath(item: lastItemIndex, section: section)
//            self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: false)
//        }
    
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
    
    var selectIndex = -1
    
    let interactor = Interactor()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        self.performSegue(withIdentifier: "Home_Single", sender: self)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SinglePageView") as! SelectSinglePageView
        vc.transitioningDelegate = self
        vc.interactor = interactor
        vc.passDataInfo = self.cardArr[selectIndex]
        
        presentVCRightToLeft(self, vc)
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardArr.count
    }
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Searching", for: indexPath) as! SearchResultCollectionViewCell
        
        let radius = cell.profileImageView.frame.size.height / 2
        cell.profileImageView.layer.cornerRadius = radius
        cell.profileImageView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 10.0
        cell.clipsToBounds = false
        cell.layer.masksToBounds = false
        
        
        cell.photoImageView.image = UIImage(named: "placeholder")
        cell.profileImageView.image = UIImage(named: "placeholder")
        
        let urlCard = URLRequest(url: URL(string: "http://www.roop.xyz\(cardArr[indexPath.row].cardPhotoAddress!)")!)
        let urlProfile = URLRequest(url: URL(string: "https:\(self.cardArr[indexPath.row].profilePhotoAddress!)")!)
        
        imageDownloader.download(urlCard) { response in
            
            if let image = response.result.value {
                cell.photoImageView.image = image
            }
        }
        imageDownloader.download(urlProfile) { response in
            
            if let image = response.result.value {
                cell.profileImageView.image = image
            }
        }
        
        cell.userName.text = cardArr[indexPath.row].userName
        cell.email.text = cardArr[indexPath.row].email! + "\(indexPath.row)"
        cell.likeCount.text = ("\(cardArr[indexPath.row].likeCount!)")
        cell.viewCount.text = ("\(cardArr[indexPath.row].viewCount!)")
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let tempPixel = self.cardArr[indexPath.row].pixel
        let pixelHeight = (tempPixel?["h"] as! NSString).integerValue
        let pixelWidth = (tempPixel?["w"] as! NSString).integerValue
        var cellSizes: [CGSize] = []
        for _ in 0...self.cardArr.count {
            
            cellSizes.append(CGSize(width: pixelWidth, height: pixelHeight))
        }
        return cellSizes[(indexPath as NSIndexPath).item]
    }
    
    func cellTapped(_ cell: SearchResultCollectionViewCell) {
        let idx = collectionView.indexPath(for: cell)!.row
        print("funcfuncfunc\(idx)")
        print("http://www.roop.xyz/api/look/upvote/\(cardArr[idx]._id!)")
        Alamofire.request("http://www.roop.xyz/api/look/upvote/\(cardArr[idx]._id!)?access_token=\(self.getToken)", method: .put).responseJSON{
            response in
            do{
                let json = try? JSONSerialization.jsonObject(with: response.data!, options:.allowFragments) as! [String:Any] // [[String:AnyObject]]
                print("++tapppppppp++")
                
                if(!cell.likeStatus){
                    
                    self.cardArr[idx].likeCount = json?["upVotes"] as! Int?
                    cell.likeCount.text = "\(self.cardArr[idx].likeCount!)"
                    cell.roopingIcon_off.isHidden = true
                    cell.roopingIcon_on.isHidden = false
                }else{
                    self.cardArr[idx].likeCount = json?["upVotes"] as! Int?
                    cell.likeCount.text = "\(self.cardArr[idx].likeCount!)"
                    cell.roopingIcon_off.isHidden = false
                    cell.roopingIcon_on.isHidden = true
                }
                
            }catch {
                print("Error with Json: \(error)")
            }
            
        }
    }
    
    
    func loadCardView(){
        let parameters: Parameters = [
            "keyword": "\(self.keyword)",
            "searchKeyword": "searchKeyword"
        ]
        
        Alamofire.request("http://www.roop.xyz/api/look/getSearchResult?access_token=\(getToken)", method: .post, parameters: parameters).responseJSON{ response in
            print("++++++++++++++++++++Searching++++++=")
            print(response)
            if let JSON = response.result.value as! [AnyObject]! {
                var cardView : CardViewData
                for i in 0..<JSON.count {
                    cardView = CardViewData()
                    cardView.cardPhotoAddress = JSON[i]["image"]! as? String
                    cardView.profilePhotoAddress = JSON[i]["userGravatar"]! as? String
                    cardView.userName = JSON[i]["userName"]! as? String
                    cardView.email = JSON[i]["email"]! as? String
                    cardView.pixel = JSON[i]["pixel"] as? NSDictionary
                    cardView.createTime = JSON[i]["createTime"] as? String
                    cardView.ansBrandname = JSON[i]["ansBrandname"] as? String
                    cardView.ansColor = JSON[i]["ansColor"] as? String
                    cardView.ansDescription = JSON[i]["ansDescription"] as? String
                    cardView.ansLink = JSON[i]["ansLink"] as? String
                    cardView.ansPrice = JSON[i]["ansPrice"] as? Int
                    cardView.ansSex = JSON[i]["ansSex"] as? String
                    cardView.ansSize = JSON[i]["ansSize"] as? String
                    cardView.viewCount = JSON[i]["views"] as? Int
                    cardView.likeCount = JSON[i]["upVotes"] as? Int
                    self.cardArr.append(cardView)
                }
                print("======kikik===========")
                print(self.cardArr.first)
                self.collectionView.reloadData()
            } else if let error = response.result.error {
                print("Error: \(error)")
                // Notify user of the error in the appropriate way
            }
        }
        
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

}
