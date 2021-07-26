//
//  LocationHandler.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import Foundation
import WebKit
import CoreLocation

class LocationHandler: NSObject, WKScriptMessageHandler,CLLocationManagerDelegate {
    var bridgeView: BridgeView
    init(bridgeView: BridgeView) {
        self.bridgeView = bridgeView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "getLocation": getLocation()
        default:
            return
        }
    }

    func getLocation() {
        
     let locationManager = CLLocationManager()
        var userLatitude:CLLocationDegrees! = 0
        var userLongitude:CLLocationDegrees! = 0
        
        if CLLocationManager.locationServicesEnabled() {
            UserDefaults.standard.set(true, forKey: "location")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()

            userLatitude  = locationManager.location?.coordinate.latitude
            userLongitude  = locationManager.location?.coordinate.longitude
            
            self.bridgeView.evaluate(JS: "callbackLocation({location: '\("Currentlocation userLatitude is \(userLatitude!)")and userLongitude is \(userLongitude!)'})")
        } else {
            
            UserDefaults.standard.set(false, forKey: "location")
        }
       
    }
}
