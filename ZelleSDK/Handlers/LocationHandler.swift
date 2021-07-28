//
//  LocationHandler.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import Foundation
import WebKit
import MapKit

/*
 * This class handles location related functionlities.
 * getLocation method returns the lattitude & longitude of the current location to javascript.
*/

class LocationHandler: NSObject, WKScriptMessageHandler ,CLLocationManagerDelegate {
    var bridgeView: BridgeView
    
    var locManager = CLLocationManager()
       var currentLocation: CLLocation!
    
    var manager:CLLocationManager!
       var locationManager:CLLocationManager!

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
    
    /*
     * This method returns the lattitude & longitude of the current location to javascript.
    */
    
    func getLocation() {
        //locManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
          if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                guard let currentLocation = locManager.location else {
                    return
          }
            self.bridgeView.evaluate(JS: "callbackLocation({location: '\("Lattitude \(currentLocation.coordinate.latitude) and Longtitude \(currentLocation.coordinate.longitude)")'})")
            }
        }
    }
    }



  




