//
//  Permission.swift
//  ZelleSDK
//
//  Created by Jayant Tiwari on 23/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import Foundation

struct Permission : Codable {
    
    var contact : Bool?
    var camera : Bool?
    var photos : Bool?
    var location : Bool?
    
    init(contact : Bool, camera : Bool, photos : Bool, location : Bool) {
        self.contact = contact
        self.camera = camera
        self.photos = photos
        self.location = location
        
    }
    
}
