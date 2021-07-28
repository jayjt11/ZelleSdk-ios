//  SessionHandler.swift
//  ZelleSDK
//  Created by Fiserv on 08/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import Foundation
import WebKit

/*
 * This class handles share content related functionlities.
 * sharePhoto method takes the values from javascript as base64, converts this to bitmap & displays the popup to the user to the share the photo.
 * shareText method takes the values from javascript as string, displays the popup to the user to the share the text.
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
     * This method takes the values from javascript as base64, converts this to bitmap & displays the popup to the user to the share.
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
    * This method takes the values from javascript as string, displays the popup to the user to the share the text.
    */

    func shareText() {
        
        let text = "Welcome to ZelleSDK"
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
             activityViewController.popoverPresentationController?.sourceView = bridgeView
          viewController?.present(activityViewController, animated: true, completion: nil)
    }
}
