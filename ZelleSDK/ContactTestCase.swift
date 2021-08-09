//
//  Contacts.swift
//  ZelleSDK
//
//  Created by Jayant Tiwari on 09/08/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import Foundation

class ContactTestCase {
    
    func getSingleContact() -> Contact1 {
        let contat1 = Contact1(name: "Jayant Tiwari", email: "xyz@gmail.com")
        return contat1
    }
    
    
    func getAllContacts() -> [Contact1] {
        
        var arrContacts = [Contact1]()
        let contatPhone = Contact1(name: "Jayant Tiwari", phone: "98676008866")
        let contatEmail = Contact1(name: "Jayant Tiwari", email: "xyz@gmail.com")
        arrContacts.append(contatPhone)
        arrContacts.append(contatEmail)
        
        return arrContacts
    }
}
