//
//  LocationHandler.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import Foundation
import WebKit
import CoreLocation

/*
 * This class handles location related functionlities.
 * getLocation method returns the lattitude & longitude of the current location to javascript.
*/
class LocationHandler: NSObject, WKScriptMessageHandler ,CLLocationManagerDelegate {
  var bridgeView: BridgeView

     var locationManager:CLLocationManager?
    var viewController: UIViewController?


 init(bridgeView: BridgeView, viewController: UIViewController?) {
      self.bridgeView = bridgeView
      self.viewController = viewController
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

    self.getUserLocation()
  }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil

        self.bridgeView.evaluate(JS: "callbackLocation({location: '\("Lattitude \(locValue.latitude) and Longtitude \(locValue.longitude)")'})")
        
    }
    
   
    
    func getUserLocation() {
   locationManager = CLLocationManager()
 locationManager?.delegate = self
   locationManager?.requestAlwaysAuthorization()
   locationManager?.startUpdatingLocation()
 }
  }








