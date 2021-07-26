//
//  PermissionsHandler.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import Foundation
import WebKit

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
    
    func checkPermissions() {
        
        var contact = UserDefaults.standard.bool(forKey: "contact")
        var camera = UserDefaults.standard.bool(forKey: "camera")
        var photos = UserDefaults.standard.bool(forKey: "photos")
        var location = UserDefaults.standard.bool(forKey: "location")
        
        var permission = Permission(contact: contact, camera: camera, photos: photos, location: location)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(permission)
        let jsonPermission = String(data: jsonData, encoding: String.Encoding.utf8)
        
        self.bridgeView.evaluate(JS: "callbackPermissions({permission :' \(String(describing: jsonPermission!))'})")
        
//        self.bridgeView.evaluate(JS: "callbackPermissions({permission: '\("Check permissions feature is in progress, Available Soon")'})")
        
    }
}
