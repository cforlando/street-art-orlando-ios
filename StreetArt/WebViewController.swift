//
//  WebViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 9/25/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView!

    var url: URL?

    init(url: URL?) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.ignoresViewportScaleLimits = false
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)

        self.view.addSubview(webView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        if let url = self.url {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            dLog("url is null")
        }
    }

}
