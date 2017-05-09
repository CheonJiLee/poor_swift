//
//  SelectPhotoAlbum.swift
//  roop
//
//  Created by 이천지 on 2016. 10. 9..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import Photos

class SelectPhotoAlbum :UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet var photoLibraryCollectionView: UICollectionView!
    
    @IBOutlet var selectedImage: UIImageView!
    
    var fetchResult: PHFetchResult<AnyObject>!
    var imageArr = [UIImage]()
    
    override func viewDidLoad() {
        let navigationBarAppear = UINavigationBar.appearance()
        navigationBarAppear.barTintColor = UIColor.white
        // get rid of black bar underneath navbar
        navigationBarAppear.shadowImage = UIImage()
        navigationBarAppear.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.isTranslucent = false
        
        photoLibraryCollectionView.delegate = self
        photoLibraryCollectionView.dataSource = self
        self.tabBarController?.tabBar.isHidden = true
        //camera제어 부분
        
        self.photoLibraryCollectionView.reloadData()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        imageArr = []
        selectedImage.image = nil;
        let initImage = UIImage(named: "camera")
        imageArr.append(initImage!)
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) as! PHFetchResult<AnyObject>
        
        //staus와 옆쪽채우기 위해서 하는 작업
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
        self.tabBarController?.tabBar.isHidden = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.grabPhotos(index: 0)
    }
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    var selectdeNum = -1
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.imageArr.count > 1{
            return self.imageArr.count
        }else{
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectdeNum = indexPath.row
        
        if(selectdeNum == 0){
            print("zzzzzzzzzz")
            performSegue(withIdentifier: "connectCamera", sender: indexPath)
        }
        photoLibraryCollectionView?.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! CameraCollectionViewCell
        
//        if(selectdeNum == 0){
//            selectedImage.image = nil
//        }
        if(selectdeNum == indexPath.row){
            selectedImage.image = imageArr[indexPath.row]
        }
        if(indexPath.row == 0){
            cell.thumbNail.image = imageArr[0]
        }else{
            if cell.thumbNail.image == nil{
                cell.thumbNail.image = UIImage(named: "placeholder")
            }else{
                
                cell.thumbNail.image = imageArr[indexPath.row]
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 4 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        if(selectdeNum != -1){
            
            if(segue.identifier == "connectAlbum"){
                let destination = segue.destination as! RegisterNew
                destination.setImage = self.selectedImage.image!
            }
        }
    }
    
    func grabPhotos(index: Int) {
        
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        
        if fetchResult.count > 0 {
            imgManager.requestImage(for: fetchResult.object(at: index) as! PHAsset , targetSize: CGSize(width: 200, height:200), contentMode: .aspectFill , options: requestOptions, resultHandler:
                {
                    image, error in
                    self.imageArr.append(image!)
                    
                    if index < self.fetchResult.count - 1 {
                        self.grabPhotos(index: index + 1)
                    }
                    else{
                        print("========end==========")
                    }
                    print("============image===========")
                    print("\(self.fetchResult.count) / \(index)")
                    self.photoLibraryCollectionView.reloadData()
                        
                })
        }
        else{
            print("You got no photos ")
            //photoLibraryCollectionView?.reloadData()
        }
    }
}
