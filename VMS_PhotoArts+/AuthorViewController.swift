//
//  AuthorViewController.swift
//  ClientDatabase
//  This file loads the User Portfolio Page in a WebView
//  Created by Vijay Murugappan Subbiah on 9/27/17.
//  Copyright © 2017 Vijay Murugappan Subbiah. All rights reserved.
//

import UIKit

class AuthorViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    //Getting the url file and loading the request
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "index", withExtension: "html")
        let URLObj = URLRequest(url: url!)
        webView.loadRequest(URLObj);
    }
}
