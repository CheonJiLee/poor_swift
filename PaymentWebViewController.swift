//
//  PaymentWebViewController.swift
//  roop
//
//  Created by 이천지 on 2016. 12. 31..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

class PaymentWebViewController: UIViewController,UIWebViewDelegate{
    @IBOutlet weak var paymentWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadHtmlFile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        //ISP 호출하는 경우
//        if URLString.hasPrefix("ispmobile://") {
//            var appURL = URL(string: URLString)!
//            if UIApplication.shared.canOpenURL(appURL) {
//                UIApplication.shared.openURL(appURL)
//            }
//            else {
////                self.showA
////                self.showAlertView(withEvent: "모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다.", tagNum: 99)
//                return false
//            }
//        }
//    }
//    
    func loadHtmlCode() {
        let htmlCode = "<html><head><title>Wonderful web</title></head> <body><p>wonderful web. loading html code in <strong>webview</strong></></body>"
        paymentWebView.loadHTMLString(htmlCode, baseURL: nil)
    }
    
    func loadHtmlFile() {
        let url = Bundle.main.url(forResource: "home", withExtension:"html")
        let request = URLRequest(url: url!)
        paymentWebView.loadRequest(request)
    }
    
    
}
