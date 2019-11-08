//
//  WebView+Extension.swift
//  WKWebViewDemo
//
//  Created by 周正飞 on 2019/11/8.
//  Copyright © 2019 周正飞. All rights reserved.
//

import Foundation
import WebKit

private var messageDelegateKey: Void?

typealias ScriptMessageHandler = (WKScriptMessage) -> Void

extension WKWebView {
    private var messageProxy: MessageHandlerProxy? {
        get {
            return objc_getAssociatedObject(self, &messageDelegateKey) as? MessageHandlerProxy
        }
        set {
            objc_setAssociatedObject(self, &messageDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 添加与H5交互Message
    func addMessageHandler(with name: String, messageHandler: @escaping ScriptMessageHandler) {
        let messageProxy = self.messageProxy ?? MessageHandlerProxy()
        configuration.userContentController.add(messageProxy, name: name)
        messageProxy.add(name: name, handler: messageHandler)
    }
}


private class MessageHandlerProxy: NSObject, WKScriptMessageHandler {
    private var messageHandlers: [String: ScriptMessageHandler] = [:]
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let handler = messageHandlers[message.name] {
            handler(message)
        } else {
            debugPrint("收到未定义的scriptHandlerName ", message.name)
        }
    }
    
    func add(name: String, handler: @escaping ScriptMessageHandler) {
        messageHandlers[name] = handler
    }
}
