//
//  Fiserv
//
//  Created by omar.ata on 4/9/21.
//

import UIKit
import WebKit
import QRCodeReader
import Photos

// , QRCodeReaderViewControllerDelegate protocol

/*
 * This class handles QR code related functionlities.
 * scanCode method scans the QR code from camera, reads it & passes the result back to javascript.
 * selectQRCodeFromPhotos method selects QR code from gallery/External Storage, reads it & passes the result back to javascript.
*/

class QRCodeHandler: NSObject, WKScriptMessageHandler, UINavigationControllerDelegate,UIImagePickerControllerDelegate, QRCodeReaderViewControllerDelegate  {
     var counter : Int = 0

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
     * QRCodeHandler  class has been implemented here to perform their actions.
    */
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "scanQRCode": scanCode()
        case "selectQRCodeFromPhotos": selectQRCodeFromPhotos()
        default:
            return
        }
    }
    
   /*
    * This method scans the QR code from camera, reads it & passes the result back to javascript.
   */
    
    func scanCode() {
        
    //   self.bridgeView.evaluate(JS: "callbackQRCode({code: 'scanning ...'})")

        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton        = true
            $0.showSwitchCameraButton = true
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.3, width: 0.6, height: 0.4)
        }
        
        let reader = QRCodeReaderViewController(builder: builder)
        reader.delegate = self
        viewController?.present(reader, animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "camera")
    }
    
    /*
     * Qr code callback methods
     * Here the result will be sent to Javacript.
    */
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
        viewController?.dismiss(animated: true, completion: nil)
        
        let code = result.value
        if code != ""  {
                    
                    let jsonData = code.data(using: .utf8)!
                    let qrCode: QRCode = try! JSONDecoder().decode(QRCode.self, from: jsonData)
                
                    if (qrCode.phone != nil) && (qrCode.email != nil) {
                        self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid QR code")'})")
                        
                    } else if qrCode.phone == nil {
                        
                        if validateName(name: qrCode.name) {
                            
                            if qrCode.email!.isValidEmail() {
                                self.bridgeView.evaluate(JS: "callbackQRCode({code: 'Name : \(qrCode.name), Email: \(qrCode.email!) '})")
                            } else {
                               
                                self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid Email")'})")
                            }
                            
                        } else {
                            
                            self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid Name")'})")
                        }
                    }
                    else if qrCode.email == nil {

                        if validateName(name: qrCode.name) {
                            
                            if qrCode.phone!.isValidPhoneNumber() {
                                self.bridgeView.evaluate(JS: "callbackQRCode({code: 'Name : \(qrCode.name), Phone: \(qrCode.phone!) '})")
                            } else {
                                self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid Phone")'})")
                            }
                        } else {
                            self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid Email")'})")
                        }
                    }
                }
                else {
                    self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid QR code")'})")
                }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
        viewController?.dismiss(animated: true, completion: nil)
        self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("User Cancelled the permission")'})")
    }
    
    /*
     * This method selects QR code from gallery/External Storage, reads it & passes the result back to javascript.
    */
    
    func selectQRCodeFromPhotos() {

        DispatchQueue.main.async {
         PHPhotoLibrary.requestAuthorization({status in
             if status == .authorized {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "photos")
                    self.Gallery()
                }
             } else {
                DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: "photos")
                if self.counter > 0 {
                self.showSettingsAlerts { (Bool) in }
                }
                self.counter += 1
                }
            }
         })
        }
    }
    
    
    func Gallery() {
        
       if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
       
        let imageController = UIImagePickerController()
         imageController.delegate = self
         imageController.allowsEditing = true
         imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
         viewController?.present(imageController, animated: true, completion: nil)
        }
        else {
        let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //viewController?.present(alert, animated: true, completion: nil)
        viewController?.dismiss(animated: true, completion: nil)
        
        self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("You don't have permission to access gallery.")'})")
        }
    }
    
    func validateName(name: String) -> Bool {
        
        if name != "" && name.count>=2 && ((name.count<=30) || (name.count<=255)) {
            return true
        }
        else {
           return false
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        viewController?.dismiss(animated: true, completion: nil)

        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                      context: nil,
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
            let ciImage = CIImage(image: pickedImage),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else { return }

        let code = features.reduce("") { $0 + ($1.messageString ?? "") }
        
        if code != ""  {
            
            let jsonData = code.data(using: .utf8)!
            let qrCode: QRCode = try! JSONDecoder().decode(QRCode.self, from: jsonData)
            
            if (qrCode.phone != nil) && (qrCode.email != nil) {
                self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid QR code")'})")
                
            } else if qrCode.phone == nil {
                
                if validateName(name: qrCode.name) {
                    if qrCode.email!.isValidEmail() {
                        self.bridgeView.evaluate(JS: "callbackQRCode({code: 'Name : \(qrCode.name), Email: \(qrCode.email!) '})")
                    } else {
                        self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid Email")'})")
                    }
                } else {
                    self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid Name")'})")
                }
            }
            else if qrCode.email == nil {
                
                if validateName(name: qrCode.name) {
                    
                    if qrCode.phone!.isValidPhoneNumber() {
                        self.bridgeView.evaluate(JS: "callbackQRCode({code: 'Name : \(qrCode.name), Phone: \(qrCode.phone!) '})")
                    } else {
                        self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid Phone")'})")
                    }
                } else {
                    self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid Email")'})")
                }
            }
        }
        else {
            self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid QR code")'})")
        }
    }
    
    /*
     * Here we are checking threeshold count and show the alertview to Navigate the settings page.
    */
    
    func showSettingsAlerts(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        
        var title = UserDefaults.standard.string(forKey: "title")
         let alert = UIAlertController(title: title, message: "This app requires access to Gallery  to proceed. Go to Settings to grant access.", preferredStyle: .alert)
         if
             let settings = URL(string: UIApplication.openSettingsURLString),
             UIApplication.shared.canOpenURL(settings) {
                 alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                     completionHandler(false)
                     UIApplication.shared.open(settings)
                 })
         }
         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
             completionHandler(false)
         })
         viewController?.present(alert, animated: true)
     }
}
