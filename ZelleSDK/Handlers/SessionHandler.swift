
//  SessionHandler.swift
//  ZelleSDK
//  Created by Fiserv on 08/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//
import Foundation
import WebKit


/*
 * This class handles session related functionlities.
 * sessionTimeout method displays the popup asking user to close the session or continue the current session.
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
     * Session handler class has been implemented here to perform their actions.
    */
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "sessionTimeout": sessionTimeout()
        default:
            return
        }
    }
    
    /*
     *  This method displays the popup asking user to close the session or continue the current session.
    */

    func sessionTimeout() {
        
        let alert = UIAlertController(title: "Session Timeout", message: "Session is about to expire, Do you want to continue?", preferredStyle: .alert)
            
        alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { _ in
                
               DispatchQueue.main.async {
                alert.dismiss(animated: true)
               }
            }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

           DispatchQueue.main.async {
            exit(0)
           }
        
        DispatchQueue.main.async {
            self.viewController?.present(alert, animated: true, completion: nil)
        }
    }
    
}

