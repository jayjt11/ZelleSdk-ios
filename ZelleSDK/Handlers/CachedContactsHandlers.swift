//
//  CachedContactsHandlers.swift
//  ZelleSDK
//
//  Created by Jayant Tiwari on 28/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

//
//  Fiserv
//
//  Created by omar.ata on 4/9/21.
//
import UIKit
import WebKit
import Contacts
import JavaScriptCore

class CachedContactsHandlers: NSObject, WKScriptMessageHandler {
    private let cacheValidityPeriod = 86400.0 //one day
    var bridgeView: BridgeView
    var viewController: UIViewController?
    
//    init(bridgeView: BridgeView) {
//        self.bridgeView = bridgeView
//    }
    
    init(bridgeView: BridgeView, viewController: UIViewController?) {
        self.bridgeView = bridgeView
        self.viewController = viewController
    }



    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "getContacts": getContacts()
        case "getOneContact": getOneContact()
        default:
            return
        }
    }

    func getContacts() {
        //check TS of last caching
        print("######### Getting from local cache")
        if let lastCacheTS = UserDefaults.standard.object(forKey: "cachedContactsTS") as? Date {
            let timeInterval = Date().timeIntervalSince(lastCacheTS)
            if (Date().timeIntervalSince(lastCacheTS) < cacheValidityPeriod) {
                if let cachedContacts = UserDefaults.standard.array(forKey: "cachedContacts") {
                    self.bridgeView.evaluate(JS: "var cachedContacts = \(cachedContacts);") //{ print($0, $1) }
                    self.bridgeView.evaluate(JS: "callbackContacts({cached: true})") //{ print($0, $1) }
                    return
                }
            }
        }

        //else, read local contacts
        print("######### Getting from contact list")
        let store = CNContactStore()
        do {
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            var count = 0
            self.bridgeView.evaluate(JS: "var cachedContacts = [];")
            try store.enumerateContacts(with: fetchRequest) { (contact, _) in
                count += 1

                if (!contact.givenName.isEmpty) {
                    var queue = ""

                    for number in contact.phoneNumbers {
                        //do something with the phone numbers
                        queue += """
                            cachedContacts.push(
                                {
                                    firstName: "\(contact.givenName)",
                                    lastName: "\(contact.familyName)",
                                    tokenType: "phone",
                                    tokenValue: "\(number.value.stringValue)",
                                }
                            );
                        """
                    }

                    for email in contact.emailAddresses {
                        queue += """
                            cachedContacts.push(
                                {
                                    firstName: "\(contact.givenName)",
                                    lastName: "\(contact.familyName)",
                                    tokenType: "email",
                                    tokenValue: "\(email.value)",
                                }
                            );
                        """
                    }

                    self.bridgeView.evaluate(JS: queue)
                }

                //save TS of last caching
                UserDefaults.standard.set(Date(), forKey: "cachedContactsTS")
            }

            self.bridgeView.evaluate(JS: "callbackContacts({cached: true})")
        } catch {
            print("Failed to fetch contact, error: \(error)")
        }
    }

    func getOneContact() {
    }
}
