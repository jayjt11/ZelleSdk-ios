//
//  Util.swift
//  ZelleSDK
//
//  Created by Jayant Tiwari on 05/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import UIKit

class Util {
    
    // convert to base64
    static func convertImageToBase64String (img: UIImage) -> String {
                let imageData:NSData = img.jpegData(compressionQuality: 0.20)! as NSData //UIImagePNGRepresentation(img)
                let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
                return imgString
    }
}
