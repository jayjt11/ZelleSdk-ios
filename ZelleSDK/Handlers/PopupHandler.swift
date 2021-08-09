//
//  Fiserv
//
//  Created by omar.ata on 4/9/21.
//

import UIKit
import WebKit
import QRCodeReader

class PopupHandler: NSObject, WKScriptMessageHandler {

   /*
    * This method intiliazes the PopupHandler class with paramemters bridgeView & viewController.
    */
    var bridgePopup: BridgePopup
    init(bridgePopup: BridgePopup) {
        self.bridgePopup = bridgePopup
    }
    
    /*
     *This method interacts with javascript & returns the method name called by javascript postmessage method.
    */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "dismissPopup":
            dismissPopup()
        default:
            return
        }
    }
    
    
    func dismissPopup() {
        bridgePopup.removeFromSuperview()
    }
}
