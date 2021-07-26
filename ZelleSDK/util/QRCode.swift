//
//  QRCode.swift
//  ZelleSDK
//
//  Created by Jayant Tiwari on 08/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import Foundation

struct QRCode : Decodable {
    
    var name : String
    var phone : String?
    var email : String?
    
    init(name : String, phone : String, email : String) {
        self.name = name
        self.phone = phone
        self.email = email
    }
    
}
