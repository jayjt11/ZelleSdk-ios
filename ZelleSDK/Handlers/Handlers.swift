//
//  Handlers.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import UIKit
import WebKit

func configureHandlers(for bridgeView: BridgeView) -> WKWebViewConfiguration {
    let config = WKWebViewConfiguration()

    let contactsHandler = ContactsHandler(bridgeView: bridgeView, viewController: bridgeView.viewController)
    config.userContentController.add(contactsHandler, name: "getContacts")
    config.userContentController.add(contactsHandler, name: "getOneContact")
    
//    let contactsHandler = CachedContactsHandlers(bridgeView: bridgeView, viewController: bridgeView.viewController)
//    config.userContentController.add(contactsHandler, name: "getContacts")
//    config.userContentController.add(contactsHandler, name: "getOneContact")

    let qrCodeHandler = QRCodeHandler(bridgeView: bridgeView, viewController: bridgeView.viewController)
    config.userContentController.add(qrCodeHandler, name: "scanQRCode")
    config.userContentController.add(qrCodeHandler, name: "selectQRCodeFromPhotos")

    let photosHandler = PhotosHandler(bridgeView: bridgeView, viewController: bridgeView.viewController)
    config.userContentController.add(photosHandler, name: "takePhoto")
    config.userContentController.add(photosHandler, name: "selectFromPhotos")

    let shareHandler = ShareHandler(bridgeView: bridgeView, viewController: bridgeView.viewController)
    config.userContentController.add(shareHandler, name: "sharePhoto")
    config.userContentController.add(shareHandler, name: "shareText")
    
    let sessionHandler = SessionHandler(bridgeView: bridgeView, viewController: bridgeView.viewController)
    config.userContentController.add(sessionHandler, name: "sessionTimeout")
    
    let locationHandler = LocationHandler(bridgeView: bridgeView)
    config.userContentController.add(locationHandler, name: "getLocation")
    
    let permissionsHandler = PermissionsHandler(bridgeView: bridgeView)
    config.userContentController.add(permissionsHandler, name: "checkPermissions")

    return config
}
