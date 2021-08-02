//
//  Fiserv
//
//  Created by omar.ata on 4/9/21.
//

import UIKit
import WebKit



public class BridgeView: UIView, BridgeDelegate, WKUIDelegate {

public var webView: WKWebView?
internal var config: BridgeConfig
internal var viewController: UIViewController

//initWithFrame to init view from code
public init(frame: CGRect, config: BridgeConfig, viewController: UIViewController) {
    self.viewController = viewController
    self.config = config
    super.init(frame: frame)
    setupView()
}

//initWithCode to init view from xib or storyboard
required init?(coder aDecoder: NSCoder) {
    config = RawConfig(url: "")
    viewController = UIViewController()
    super.init(coder: aDecoder)
    setupView()
}

override public func removeFromSuperview() {
    //BridgeView about to be dismissed
    //save a copy of cachedContacts
   // saveCachedContacts()
    
    super.removeFromSuperview()
}

//common func to init our view
private func setupView() {
    webView = WKWebView(frame: .zero, configuration: configureHandlers(for: self))
    webView!.configuration.preferences.javaScriptEnabled = true
    addSubview(webView!)
    webView!.translatesAutoresizingMaskIntoConstraints = false
    webView!.uiDelegate = self

    let constraints = [
        NSLayoutConstraint(item: webView!, attribute: .top,    relatedBy: .equal, toItem: self, attribute: .top,    multiplier: 1, constant: 0),
        NSLayoutConstraint(item: webView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: webView!, attribute: .left,   relatedBy: .equal, toItem: self, attribute: .left,   multiplier: 1, constant: 0),
        NSLayoutConstraint(item: webView!, attribute: .right,  relatedBy: .equal, toItem: self, attribute: .right,  multiplier: 1, constant: 0),
    ]
    NSLayoutConstraint.activate(constraints)
    
    load()
}

public func load() {
    let url = URL(string: config.url)!
    self.webView?.load(URLRequest(url: url))
}

public func evaluate(JS: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
    webView?.evaluateJavaScript(JS, completionHandler: completionHandler)
}

    public func saveCachedContacts(cachedContacts : String) {
   
    // Old logic
    
//    evaluate(JS: "cachedContacts.length > 0 ? cachedContacts : undefined") { result, err in
//        if err == nil {
//            if let cachedContacts = result {
//
//                //save a copy of cachedContacts
//                print("User Defaults contact \(String(describing: result))")
//                UserDefaults.standard.set(cachedContacts, forKey: "cachedContacts")
//                UserDefaults.standard.set(Date(), forKey: "cachedContactsTS")
//            }
//        }
//    }
    
    // New Logic
    
       // print("User Defaults contact \(String(describing: result))")
        UserDefaults.standard.set(cachedContacts, forKey: "cachedContacts")
        UserDefaults.standard.set(Date(), forKey: "cachedContactsTS")
    
}
    
    // callback methods
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))

        viewController.present(alertController, animated: true, completion: nil)
    }


    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))

        viewController.present(alertController, animated: true, completion: nil)
    }


    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {

        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))

        viewController.present(alertController, animated: true, completion: nil)
    }
}
