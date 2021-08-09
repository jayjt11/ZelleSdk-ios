//
//  PhotosHandler.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import Foundation
import WebKit
import Photos



/*
 * PhotosHandler class handles the Photos related functionalities.
 * takePhoto function is used to take photo from camera.
 * selectFromPhotos method is used to selects photo from gallery/External Storage, converts the photo to base64 & passes the result back to javascript.
*/

class PhotosHandler: NSObject, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var bridgeView: BridgeView
    var viewController: UIViewController?
    var imageController = UIImagePickerController()
    var accessStatus:Bool?
    var counter : Int = 0

   
    /*
    * This method intiliazes the PhotosHandler class with paramemters bridgeView & viewController.
    */
    init(bridgeView: BridgeView, viewController: UIViewController) {
        self.bridgeView = bridgeView
        self.viewController = viewController
    }
    
    /*
     *This method interacts with javascript & returns the method name called by javascript postmessage method.
    */
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "takePhoto": takePhoto()
        case "selectFromPhotos": selectFromPhotos()
        default:
            return
        }
    }
    
    /*
    * takePhoto function is used to take photo from camera..
    */
    
    func takePhoto() {
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "camera")
                self.Camera()
            }
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: "camera")
                        self.Camera()
                    }
                } else {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(false, forKey: "camera")
                    if self.counter > 0 {
                        self.showSettingsAlerts { (Bool) in }
                    }
                    self.counter += 1
                }
                }
          })
        }
    }
    
    /*
     * This method selects photo from gallery/External Storage, converts the photo to base64 & passes the result back to javascript.
     */
    
    func selectFromPhotos() {
          
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
    
 
    
    /*
     *This method checks for permission required to read the photos
    */
      
      func showSettingsAlerts(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: Constants.cameraOrGallerymsg, preferredStyle: .alert)
          if
              let settings = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settings) {
            alert.addAction(UIAlertAction(title: Constants.settingsStr, style: .default) { action in
                      completionHandler(false)
                      UIApplication.shared.open(settings)
                  })
          }
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
              completionHandler(false)
          })
          viewController?.present(alert, animated: true)
      }
      
      func Gallery() {
        
          if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
           imageController.delegate = self
           imageController.allowsEditing = true
           imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
           viewController?.present(imageController, animated: true, completion: nil)
          }
          else {
            self.bridgeView.evaluate(JS: "callbackPhoto({photo :' \(Constants.accessDeniedGallery)'})")
          }
      }
      
      func Camera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
           imageController.delegate = self
           imageController.sourceType = UIImagePickerController.SourceType.camera
           imageController.allowsEditing = true
           viewController?.present(imageController, animated: true, completion: nil)
          }
          else {
          viewController?.dismiss(animated: true, completion: nil)
            self.bridgeView.evaluate(JS: "callbackPhoto({photo :' \(Constants.Simulatornotsupportcamera)'})")
          }
      }
    
    // Delegate Methods
       /*
       * This method used to get selected imageview .
       */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
          var selectedImage: UIImage!
        
          if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                  selectedImage = image
          }
          else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                  selectedImage = image
          }
        
        let imgName = UUID().uuidString
        let documentDirectory = NSTemporaryDirectory()
        let localPath = documentDirectory.appending(imgName)
        let data = selectedImage.jpegData(compressionQuality: 0.3)! as NSData
        data.write(toFile: localPath, atomically: true)
        var photobase64 = ""
        photobase64 = Util.convertImageToBase64String(img: selectedImage) as String
        viewController?.dismiss(animated: true, completion: nil)
        if photobase64 != "" {
            self.bridgeView.evaluate(JS: "callbackPhoto({photo :' \(photobase64)'})")
        }
    }
    
    /*
    * This method cancels the user interaction.
    */
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      
        viewController?.dismiss(animated: true, completion: nil)
        self.bridgeView.evaluate(JS: "callbackPhoto({photo :' \("User cancelled the request")'})")

    }
    
}
