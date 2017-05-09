//
//  MainviewController.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 29..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Photos

class MainviewController: UIViewController {
    
    
    @IBOutlet var homepageBtn: UIButton!
    @IBOutlet var trendingBtn: UIButton!
    
    @IBOutlet weak var mypageBtn: UIButton!
    @IBOutlet var menuPageView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //첫번째 포토라이브러리 사진
    var imageArray = [UIImage]()
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppear = UINavigationBar.appearance()
        navigationBarAppear.barTintColor = UIColor.rgb(250, green: 202, blue: 57)
        // get rid of black bar underneath navbar
        navigationBarAppear.shadowImage = UIImage()
        navigationBarAppear.setBackgroundImage(UIImage(), for: .default)
        //navigationController?.hidesBarsOnSwipe = true
        //staus와 옆쪽채우기 위해서 하는 작업
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.isTranslucent = false
        setupNavBarButtons()
        //추가되는부분
        let page1:HomeViewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeView") as! HomeViewController
        page1.view.frame = CGRect(x: 0, y: 50 , width: self.view.bounds.width, height: self.view.bounds.height)
        page1.willMove(toParentViewController: self)
        self.scrollView.addSubview(page1.view)
        self.addChildViewController(page1)
        page1.didMove(toParentViewController: self)
        
        let page2:TrendingViewController = self.storyboard!.instantiateViewController(withIdentifier: "TrendingView") as! TrendingViewController
        page2.view.frame = CGRect(x: 0, y: 50 , width: self.view.bounds.width, height: self.view.bounds.height)
        page2.willMove(toParentViewController: self)
        self.scrollView.addSubview(page2.view)
        self.addChildViewController(page2)
        page2.didMove(toParentViewController: self)
        
        let page3:MyPageMainView = self.storyboard!.instantiateViewController(withIdentifier: "MyPageView") as! MyPageMainView
        page3.view.frame = CGRect(x: 0, y: 50 , width: self.view.bounds.width, height: self.view.bounds.height)
        page3.willMove(toParentViewController: self)
        self.scrollView.addSubview(page3.view)
        self.addChildViewController(page3)
        page3.didMove(toParentViewController: self)
        //self.view.addSubview(menuPageView)
        // 3) Set up the frames of the view controllers to align
        //    with eachother inside the container view
        var adminFrame :CGRect = page1.view.frame;
        adminFrame.origin.x = adminFrame.width;
        page2.view.frame = adminFrame;
        
        var BFrame :CGRect = page2.view.frame;
        BFrame.origin.x = 2*BFrame.width;
        page3.view.frame = BFrame;
        
        
        // 4) Finally set the size of the scroll view that contains the frames
        let scrollWidth: CGFloat  = 3 * self.view.frame.width
        let scrollHeight: CGFloat  = self.view.frame.size.height
        self.scrollView!.contentSize = CGSize(width: scrollWidth, height: scrollHeight);
        
        homepageBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        //camera제어 부분
        let initImage = UIImage(named: "camera")
        imageArray.append(initImage!)
        grabPhotos()
        
        
    }
    func setupNavBarButtons() {
        let button =  UIButton(type: .custom)
        button.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 50)
        button.setImage(#imageLiteral(resourceName: "searchbar"), for: UIControlState.normal)
        //button.setTitle("Button", for: UIControlState.normal)
        button.addTarget(self, action: #selector(clickOnButton), for: UIControlEvents.touchUpInside)
        self.navigationController?.navigationBar.backgroundColor = UIColor.rgb(250, green: 202, blue: 57)
        self.navigationItem.titleView = button
        self.navigationItem.setHidesBackButton(true, animated:true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.rgb(250, green: 202, blue: 57)
    }
    
    @IBAction func trendingBtnClick(_ sender: AnyObject) {
        self.scrollView.contentOffset.x = self.view.frame.width
        sender.setTitleColor(UIColor.white, for: UIControlState.normal)
        homepageBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        mypageBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
    }
    @IBAction func hompageBtnClick(_ sender: AnyObject) {
        self.scrollView.contentOffset.x = 0
        sender.setTitleColor(UIColor.white, for: UIControlState.normal)
        trendingBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        mypageBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
    }
    
    @IBAction func mypageBtnClick(_ sender: AnyObject) {
        self.scrollView.contentOffset.x = 2 * self.view.frame.width
        sender.setTitleColor(UIColor.white, for: UIControlState.normal)
        homepageBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        trendingBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
    }
    
    
    
    @IBAction func CameraBtnAction(_ sender: AnyObject) {
       // performSegue(withIdentifier: "GetPhotoAlbum", sender: sender)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GetPhotoAlbum") {
            let destination = segue.destination as! SelectPhotoAlbum
            destination.imageArr = self.imageArray
        }
    }

    
       
    func clickOnButton() {
        
        
    }


   
    
    func grabPhotos(){
        
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        let fetchOptions = PHFetchOptions()
        //fetchOptions.fetchLimit =
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        var fetchResult: PHFetchResult<AnyObject>
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) as! PHFetchResult<AnyObject>
        print("\(fetchResult.count)")
        if fetchResult.count > 0 {
            for i in 0..<fetchResult.count{
                imgManager.requestImage(for: fetchResult.object(at: i) as! PHAsset , targetSize: CGSize(width: 200, height:200), contentMode: .aspectFill , options: requestOptions, resultHandler:
                    {
                        image, error in
                        
                        self.imageArray.append(image!)
                        
                })
            }
        }
        else{
            print("You got no photos ")
            //photoLibraryCollectionView?.reloadData()
        }
        
    }
    
    
   
    
}
