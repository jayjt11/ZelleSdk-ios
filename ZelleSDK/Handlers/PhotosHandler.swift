//
//  PhotosHandler.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import Foundation
import WebKit
import Photos

class PhotosHandler: NSObject, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var bridgeView: BridgeView
    var viewController: UIViewController?
    var imageController = UIImagePickerController()
    init(bridgeView: BridgeView, viewController: UIViewController) {
        self.bridgeView = bridgeView
        self.viewController = viewController
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "takePhoto": takePhoto()
        case "selectFromPhotos": selectFromPhotos()
        default:
            return
        }
    }
    
    func takePhoto() {
        
        let photos = PHPhotoLibrary.authorizationStatus()
               //  if photos == .notDetermined {
                     PHPhotoLibrary.requestAuthorization({status in
                         if status == .authorized{
                            
                         let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
                             alert.addAction(UIAlertAction(title: "takePhoto", style: .default, handler: { _ in
                                 
                                DispatchQueue.main.async {
                                    self.Camera()
                                }
                             }))
                         alert.addAction(UIAlertAction(title: "selectFromPhotos", style: .default, handler: { _ in
                            DispatchQueue.main.async {
                                        self.Gallery()
                                    }
                         }))
                         alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

                            DispatchQueue.main.async {
                                self.viewController?.present(alert, animated: true, completion: nil)
                            }
                         } else {
                            
                            DispatchQueue.main.async {
                                self.showSettingsAlerts { (Bool) in
                                    }
                            }
                      }
                     })
        
        // default Respone
        
//        self.bridgeView.evaluate(JS: "callbackPhoto({photo: '\("Photo feature is in progress, Available Soon")'})")
        
    }
    
    func selectFromPhotos() {
          //Photos
          DispatchQueue.main.async {
             //let photos = PHPhotoLibrary.authorizationStatus()
                 PHPhotoLibrary.requestAuthorization({status in
                     if status == .authorized{
                      self.Gallery()
                     } else {
                      self.showSettingsAlerts { (Bool) in
                      }
                  }
                 })
            // }
          }
        
        // Default callback
        
//        self.bridgeView.evaluate(JS: "callbackPhoto({photo: '\("Photo feature is in progress, Available Soon")'})")

      }
      
      func showSettingsAlerts(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
          let alert = UIAlertController(title: nil, message: "This app requires access to Gallery or Camera to proceed. Go to Settings to grant access.", preferredStyle: .alert)
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
      
      func Gallery() {
        
          if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
           imageController.delegate = self
           imageController.allowsEditing = true
           imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
           viewController?.present(imageController, animated: true, completion: nil)
          }
          else {
              self.bridgeView.evaluate(JS: "callbackPhoto({photo :' \("You don't have permission to access gallery.")'})")
          }
      }
      
      
      func Camera() {
        
          if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
          // imageController = UIImagePickerController()
           imageController.delegate = self
           imageController.sourceType = UIImagePickerController.SourceType.camera
           imageController.allowsEditing = true
           viewController?.present(imageController, animated: true, completion: nil)
          }
          else {
          self.bridgeView.evaluate(JS: "callbackPhoto({photo :' \("Simulator not support to open Camera")'})")
          }
      }
    
    // Delegate Methods
    
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
                        
        let photobase64 = Util.convertImageToBase64String(img: selectedImage) as String
        viewController?.dismiss(animated: true, completion: nil)
        self.bridgeView.evaluate(JS: "callbackPhoto({photo :' \(photobase64)'})")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      
        viewController?.dismiss(animated: true, completion: nil)
        self.bridgeView.evaluate(JS: "callbackPhoto({photo :' \("User cancelled the request")'})")

    }
    
}
