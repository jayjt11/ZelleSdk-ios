//
//  Contact1.swift
//  ZelleSDK
//
//  Created by Jayant Tiwari on 08/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import UIKit

public struct Contact1 : Codable {
    
    var name : String?
    var phone : String?
    var email : String?
    
    init(name : String, phone : String) {
        self.name = name
        self.phone = phone
    }
    
    init(name : String, email : String) {
        self.name = name
        self.email = email
    }
    
}
