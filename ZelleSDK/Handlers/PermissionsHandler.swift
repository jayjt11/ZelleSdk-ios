//
//  PermissionsHandler.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import Foundation
import WebKit

/*
 * This class handles permission related functionlities.
 * checkPermissions method returns the status of permissions required to access the functionalities.
*/

class PermissionsHandler: NSObject, WKScriptMessageHandler {
    var bridgeView: BridgeView
    
    init(bridgeView: BridgeView) {
        self.bridgeView = bridgeView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "checkPermissions": checkPermissions()
        default:
            return
        }
    }

    /*
     * This method method returns the status of permissions required to access the functionalities to the javascript.
    */
    
    func checkPermissions() {
        
        let contact = UserDefaults.standard.bool(forKey: "contact")
        let camera = UserDefaults.standard.bool(forKey: "camera")
        let photos = UserDefaults.standard.bool(forKey: "photos")
        let location = UserDefaults.standard.bool(forKey: "location")
        
        let permission = Permission(contact: contact, camera: camera, photos: photos, location: location)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(permission)
        let jsonPermission = String(data: jsonData, encoding: String.Encoding.utf8)
        
        self.bridgeView.evaluate(JS: "callbackPermissions({permission :' \(String(describing: jsonPermission!))'})")
        
    }
}
