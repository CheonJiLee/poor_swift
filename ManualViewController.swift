//
//  manualViewController.swift
//  roop
//
//  Created by 이천지 on 2016. 9. 13..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

class ManualViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet var manualEndButton: UIButton!
    @IBOutlet var manualSkipButton: UIBarButtonItem!
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manualEndButton.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.pageTitles = NSArray(objects: "01","02","03", "04", "05")
        self.pageImages = NSArray(objects: "contentsView1","contentsView1","contentsView1","contentsView1","contentsView1")
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        //posicionar en la primera
        let startVC = self.viewControllerAtIndex(0) as ContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController] , direction: .forward , animated: true, completion: nil)
        //
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height - 20)
        
        self.addChildViewController(self.pageViewController)
        
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.didMove(toParentViewController: self)
        manualEndButton.layer.cornerRadius = 30
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(_ index: Int) ->  ContentViewController{
        
        if( (self.pageTitles.count == 0) || (index >= self.pageTitles.count) ){
            return ContentViewController()
        }
        
        let vc: ContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
        
    }
    
    // MARK - PageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound){
            return nil
        }
        
        index -= 1
        manualEndButton.isHidden = true
        self.navigationItem.rightBarButtonItem = manualSkipButton
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound){
            return nil
        }
        
        index += 1
        
        if (index == self.pageTitles.count){
            manualEndButton.isHidden = false
            self.navigationItem.rightBarButtonItem = nil
            print("6번째 이다")
            return nil
        }else{
            self.navigationItem.rightBarButtonItem = manualSkipButton
            manualEndButton.isHidden = true
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}


