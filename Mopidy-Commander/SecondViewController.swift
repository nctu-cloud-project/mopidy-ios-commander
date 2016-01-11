//
//  SecondViewController.swift
//  Mopidy-Commander
//
//  Created by Chih-Yung Liang on 2016/1/11.
//  Copyright © 2016年 Chih-Yung Liang. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://140.113.65.37:6680/mopify/")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

