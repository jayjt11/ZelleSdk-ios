
//  SessionHandler.swift
//  ZelleSDK
//  Created by Fiserv on 08/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//
import Foundation
import WebKit

 /*
   
   * Session handler created to handle app Sessions.
   * this Viewcontroller will be from Javascript.
   * sessionTimeout() function used to show alertView for the end user.
    
*/
   

class SessionHandler: NSObject, WKScriptMessageHandler {
    var bridgeView: BridgeView
    var viewController: UIViewController?
    
/*
    
    * Bridgeview configuration with view and View controller.
     
*/
    
    
    init(bridgeView: BridgeView, viewController: UIViewController?) {
        self.bridgeView = bridgeView
        self.viewController = viewController
    }
    
 /*
      
    *Session handler class has been implemented here to perform their actions.
       
*/
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "sessionTimeout": sessionTimeout()
        default:
            return
        }
    }
    
/*
     
    * Alertview will show based on the action to be needed.
     
*/

    func sessionTimeout() {
        
        let alert = UIAlertController(title: "Session Timeout", message: "Session is about to expire, Do you want to continue?", preferredStyle: .alert)
            
        alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { _ in
                
               DispatchQueue.main.async {
                   exit(0)
               }
            }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

           DispatchQueue.main.async {
            alert.dismiss(animated: true)
           }
        
        DispatchQueue.main.async {
            self.viewController?.present(alert, animated: true, completion: nil)
        }
    }
    
}

