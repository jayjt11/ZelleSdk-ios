//
//  LocationHandler.swift
//  BridgeSDK
//
//  Created by fiserv on 5/26/21.
//

import Foundation
import WebKit
import CoreLocation

/*
 * LocationHandler class handles the location related functionlities.
 * getLocation method used to get the lattitude & longitude of the current location send data to javascript.
*/


class LocationHandler: NSObject, WKScriptMessageHandler ,CLLocationManagerDelegate {
  var bridgeView: BridgeView

     var locationManager:CLLocationManager?
    var viewController: UIViewController?

/*
* This method intiliazes the LocationHandler class with paramemters bridgeView & viewController.
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
      case "getLocation": getLocation()
      default:
          return
      }
  }
  
  /*
   * getLocation method used to get the lattitude & longitude of the current location send data to javascript.
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
    
   /*
    * getUserLocation method used to set the delegate for Location manager.
   */

    
  func getUserLocation() {
   locationManager = CLLocationManager()
   locationManager?.delegate = self
   locationManager?.requestAlwaysAuthorization()
   locationManager?.startUpdatingLocation()
  }
  }








