//
//  Contact.swift
//  ZelleSDK
//
//  Created by Jayant Tiwari on 01/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import UIKit

struct Contact : Codable {
    
    var name : String
    var phone : [String]
    var email : [String]
    var photo : String
    var error : ErrorObject
    
    init(name : String, phone : [String], email : [String], photo : String, error : ErrorObject) {
        self.name = name
        self.phone = phone
        self.email = email
        self.photo = photo
        self.error = error
    }
}
