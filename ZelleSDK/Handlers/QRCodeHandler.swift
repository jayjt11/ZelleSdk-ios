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
class QRCodeHandler: NSObject, WKScriptMessageHandler, UINavigationControllerDelegate,UIImagePickerControllerDelegate, QRCodeReaderViewControllerDelegate  {

    var bridgeView: BridgeView
    var viewController: UIViewController?
    init(bridgeView: BridgeView, viewController: UIViewController?) {
        self.bridgeView = bridgeView
        self.viewController = viewController
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "scanQRCode": scanCode()
        case "selectQRCodeFromPhotos": selectQRCodeFromPhotos()
        default:
            return
        }
    }
    
    func scanCode() {
        
       self.bridgeView.evaluate(JS: "callbackQRCode({qrCode: 'scanning ...'})")

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
 
        // default methods
        
//        self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("QR code feature is in progress, Available Soon")'})")
        
    }
    
   // Qr code callback methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.bridgeView.evaluate(JS: "callbackQRCode({qrCode: '\(result.value)'})")
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        self.bridgeView.evaluate(JS: "callbackQRCode({qrCode: 'no code!', error: 'canceled'})")
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    
    func selectQRCodeFromPhotos() {

        DispatchQueue.main.async {
         PHPhotoLibrary.requestAuthorization({status in
             if status == .authorized{
                DispatchQueue.main.async {
                     self.Gallery()
                }
             } else {
                DispatchQueue.main.async {
                    self.showSettingsAlerts { (Bool) in
                }
                }
          }
         })
        }
        
        //Default Callback
//        self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("QR code feature is in progress, Available Soon")'})")
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
            print(code)//Your result from QR Code
                       
            self.bridgeView.evaluate(JS: "callbackQRCode({code: '\(code)'})")
        }
        else {
            self.bridgeView.evaluate(JS: "callbackQRCode({code: '\("Invalid QR code")'})")
        }
    }
    
    func showSettingsAlerts(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
         let alert = UIAlertController(title: nil, message: "This app requires access to Gallery  to proceed. Go to Settings to grant access.", preferredStyle: .alert)
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
