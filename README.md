
## WKWebView scriptMessageHandler封装 避免循环引用,闭包式注册

## 背景
在使用WKWebView加载H5页面并实现JS与原生交互的时候我们都会选择`func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String)`

但是个人觉得这个API用起来是很不那么友好的，比如我这边注册了三个方法供JS调用，那我需要这么做

**First, 注册**

```
webView.configuration.userContentController.add(self, name: "showAlert1")
webView.configuration.userContentController.add(self, name: "showAlert2")
webView.configuration.userContentController.add(self, name: "showAlert3")
```

接下来你需要让注册的`target`遵循协议`WKScriptMessageHandler`

**实现协议方法**

```
extension XXXViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? String else { return }
        switch body {
        case "showAlert1":
        // doSomething
        case "showAlert2":
        // doSomething
        case "showAlert3":
        // doSomething
        }
    }
}
```

弊端： 
重复的代码其实还好不是问题. 但是方法名注册时候写了一次，代理中为了区分我又判断了一次方法名，写这个字符串两边是容易出错并且不好维护的，新加一个方法的时候我们注册的地方写一遍接着拉到下方在缝隙中新加一个case是一件比较old的方式. 

而且webView的`MessageHandler`注册时候是会对目标进行一次引用的. 那么这样就会有 self->webView->scriptMessageHandler->self 的循环引用发生.

我们可以经过一次封装解决这两个问题

1. 注册时候只要两个参数，方法名以及对应方法实现，找个地方存起来
2. 需要一个代理对象来遵循和实现ScriptMessageHandler协议，这个代理需要一个map来存储方法名以及对应事件，在收到messageHandler代理方法时从map中找出对应事件执行
3. 这个代理对象的生命周期要跟webView一样，不能被viewController持有


所以我们先声明一下这个代理类

```
class MessageHandlerProxy: NSObject, WKScriptMessageHandler {
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
```

利用NSObject动态添加属性的特性给webView添加一个代理实例

```
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
```
每次为webView注册JS事件时只要调webView的这个方法就好了.

```
webView.addMessageHandler(with: "showAlert1") { (message) in
    print(message.name)
}
webView.addMessageHandler(with: "showAlert2") { (message) in
    print(message.name)
}
webView.addMessageHandler(with: "showAlert13) { (message) in
    print(message.name)
}
```

注册的地方与收到此回调做的事情内聚在一起. 维护起来也比较方便. 而且也解决了循环引用的问题. 
至于removeMessgeHandler.. 对象都销毁了之后这个remove看起来没什么意义.


