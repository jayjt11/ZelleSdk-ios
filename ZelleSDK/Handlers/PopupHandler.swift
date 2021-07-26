//
//  Fiserv
//
//  Created by omar.ata on 4/9/21.
//

import UIKit
import WebKit
import QRCodeReader

class PopupHandler: NSObject, WKScriptMessageHandler {

    
    var bridgePopup: BridgePopup
    init(bridgePopup: BridgePopup) {
        self.bridgePopup = bridgePopup
    }
    
    
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
