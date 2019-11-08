//
//  BaseWebViewController.swift
//  SeekLightActor
//
//  Created by 周正飞 on 2019/11/2.
//  Copyright © 2019 周正飞. All rights reserved.
//

import UIKit
import WebKit

class BaseWebViewController: UIViewController {

    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadHTML()
    }
}

// MARK: - 基础配置
private extension BaseWebViewController {
    func loadHTML() {
        let request = Bundle.main.path(forResource: "WKWebViewJSInteraction", ofType: "html")
            .flatMap { URL(fileURLWithPath: $0) }
            .flatMap { URLRequest(url: $0) }
        webView.load(request!)
        
    }
    func setup() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), configuration: config)
        webView.addMessageHandler(with: "showSomeThing") { (message) in
            print(message.name)
        }
        view.addSubview(webView)
    }
}
