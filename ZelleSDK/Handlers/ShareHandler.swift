//  SessionHandler.swift
//  ZelleSDK
//  Created by Fiserv on 08/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import Foundation
import WebKit



/*
 * ShareHandler class handles the share related functionalities.
 * sharePhoto function is used to takes the values from javascript as base64, converts this to bitmap & displays the popup to the user to the share the photo.
 * shareText method takes the values from javascript as string, displays the popup to the user to the share the tex.
*/

class ShareHandler: NSObject, WKScriptMessageHandler {
    var bridgeView: BridgeView
    var viewController: UIViewController?
    
  
    /*
    * This method intiliazes the ShareHandler class with paramemters bridgeView & viewController.
    */

    init(bridgeView: BridgeView, viewController: UIViewController?) {
        self.bridgeView = bridgeView
        self.viewController = viewController
    }

   
   /*
    *This method interacts with javascript & returns the method name called by javascript postmessage method.
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
     * sharePhoto function is used to takes the values from javascript as base64, converts this to bitmap & displays the popup to the user to the share the photo.
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
     * shareText method takes the values from javascript as string, displays the popup to the user to the share the tex.
     */

    func shareText() {
        
        let text = Constants.testStr
        
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
             activityViewController.popoverPresentationController?.sourceView = bridgeView
          viewController?.present(activityViewController, animated: true, completion: nil)
    }
}
