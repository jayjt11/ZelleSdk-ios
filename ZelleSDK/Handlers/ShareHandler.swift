//  SessionHandler.swift
//  ZelleSDK
//  Created by Fiserv on 08/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import Foundation
import WebKit

/*
   
   * Share handler created to handle the share details passed from Javascript.
   * this Viewcontroller will be called from Javascript.
   * get base64Str from javascript on click event.
   * get the text from javascript on click event.
   * get the url from javacript on click event.
    
*/

class ShareHandler: NSObject, WKScriptMessageHandler {
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
       
  *Share handler class has been implemented here to perform their actions.

*/
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "sharePhoto": sharePhoto(base64: (message.body as! NSString))
        case "shareText": shareText()
        default:
            return
        }
    }
    
/*
       
 * this is the method for convert base64 string to Image format and show the activity in viewcontroller
        
*/
    
    func sharePhoto(base64: NSString) {
        
        let dataDecoded : Data = Data(base64Encoded: base64 as String, options: .ignoreUnknownCharacters)!
        let decodedImage = UIImage(data: dataDecoded)
        let imageV: UIImage = decodedImage!
        let activityViewController = UIActivityViewController(activityItems: [imageV], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = bridgeView
        viewController?.present(activityViewController, animated: true, completion: nil)
        
    }
/*
       
    * this is the method for share text and show the activity in viewcontroller
        
*/
    
    func shareText() {
        
        let text = "Welcome to ZelleSDK"
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
             activityViewController.popoverPresentationController?.sourceView = bridgeView
          viewController?.present(activityViewController, animated: true, completion: nil)
    }
    
}
