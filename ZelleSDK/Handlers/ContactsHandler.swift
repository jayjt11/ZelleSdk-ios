//
//  Fiserv
//
//  Created by omar.ata on 4/9/21.
//

import UIKit
import Foundation
import WebKit
import Contacts
import ContactsUI

/*
 * ContactsHandler class handles the contacts related functionalities.
 * getContacts function is used to get the all contacts from CnContact framework.
 * getOneContact function used to get single contact from Cncontact framework.
*/

class ContactsHandler: NSObject, WKScriptMessageHandler, CNContactPickerDelegate {
    var bridgeView: BridgeView
    var viewController: UIViewController?
    var counter : Int = 0
    private let cacheValidityPeriod = 86400.0 //one day
    
    /*
    * This method intiliazes the ContactsHandler class with paramemters bridgeView & viewController.
    */
       
    init(bridgeView: BridgeView, viewController: UIViewController?) {
        self.bridgeView = bridgeView
        self.viewController = viewController
    }
    
    /*
     *This method interacts with javascript & returns the method name called by javascript postmessage method.
    */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "getContacts": getContacts()
        case "getOneContact": getOneContact()
        default:
            return
        }
    }
    
    /*
     *This method fetches all the contacts from native contact app.
    */
    
    func fetchAllContact() {
        
        //check TS of last caching
    if let lastCacheTS = UserDefaults.standard.object(forKey: "cachedContactsTS") as? Date {
        let timeInterval = Date().timeIntervalSince(lastCacheTS)
        if (Date().timeIntervalSince(lastCacheTS) < cacheValidityPeriod) {
            if let cachedContacts = UserDefaults.standard.array(forKey: "cachedContacts") {
                print("######### Getting from Userdefaults")
                print("######### \(String(describing: cachedContacts))")
                self.bridgeView.evaluate(JS: "var cachedContacts = \(cachedContacts);") //{ print($0, $1) }
                self.bridgeView.evaluate(JS: "callbackContacts({cached: true})") //{ print($0, $1) }
                return
            }
        }
    }
        
    print("######### Getting from Contact")
        let store = CNContactStore()
        var arrayContact = [Contact1]()
        do {
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            var count = 0
            self.bridgeView.evaluate(JS: "var cachedContacts = [];")
            try store.enumerateContacts(with: fetchRequest) { (contact, _) in
                count += 1
                
                let firstName = contact.givenName
                let lastName = contact.familyName
                let name = firstName + " " + lastName
                var queue = ""
                if self.validateName(name: name) {
                    let contactPhoneNumbers = contact.phoneNumbers.map {
                        $0.value.stringValue }
                    
                    for number in contactPhoneNumbers {
                        let number1 = number.filter { ("0"..."9").contains($0) }
                        if number1.isValidPhoneNumber() {
                            arrayContact.append(Contact1(name: name, phone: number1))
                            queue += """
                                cachedContacts.push(
                                    {
                                        name: "\(name)",
                                        phone: "\(number1)",
                                    }
                                );
                            """
                        }
                    }
                    let contactEmailAddresses = contact.emailAddresses.map { $0.value as String }
                    let emailAddress = contactEmailAddresses.uniqued()
                    for email in emailAddress {
                        if email.isValidEmail() {
                            arrayContact.append(Contact1(name: name, email: email))
                            queue += """
                                cachedContacts.push(
                                    {
                                        name: "\(name)",
                                        email: "\(email)",
                                    }
                                );
                            """
                        }
                    }
                    self.bridgeView.evaluate(JS: queue)
                }
            }
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(arrayContact)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            
            print("json 1 \(json!)")
            self.bridgeView.saveCachedContacts(cachedContacts: json!)
            self.bridgeView.evaluate(JS: "callbackContacts({cached: true})")
            
        } catch {
            print("Failed to fetch contact, error: \(error)")
        }
        
        }
    
    /*
     *This method is used to get all contacts and send result to Javascript.
    */
    
    func getContacts() {
        
        requestAccess { (true) in
            if(true) {
                UserDefaults.standard.set(true, forKey: "contact")
                DispatchQueue.main.async {
                    self.fetchAllContact()
                }
                
            } else {
                UserDefaults.standard.set(false, forKey: "contact")
            }
        }
    }
    
    /*
     *This method checks for permission required to read the contacts
    */
 
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            
            completionHandler(true)
        case .denied:
            
            
            if self.counter > 0 {
                showSettingsAlert(completionHandler)
            }
            counter += 1
           //
        case .restricted, .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                   
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        
                        if self.counter > 0 {
                            self.showSettingsAlert(completionHandler)
                        }
                        self.counter += 1
                    }
                }
            }
        }
    }
    
    /*
    * This method checks for threeshold count and show the alertview to Navigate the settings page.
    */
    
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        
        let title = UserDefaults.standard.string(forKey: "title")
        let alert = UIAlertController(title: title, message: Constants.contactMsg, preferredStyle: .alert)
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
    
    /*
    * This method is used to get the single contact and send result to Javascript.
    */
    
    func getOneContact() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        viewController?.present(contactPicker, animated: true, completion: nil)
    }
    
    /*
    * This method validates the contact name.
    */
    
    func validateName(name: String) -> Bool {
        
        if name != "" && name.count>=2 && ((name.count<=30) || (name.count<=255)) {
            return true
        }
        else {
           return false
        }
        
    }
    
    // CNContactPickerDelegate methods
    
    /*
    * This method allows user to select single contact & navigates to detial page, where user can select the phone number or email.
    */
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        
        let firstName = contactProperty.contact.givenName
        let lastName = contactProperty.contact.familyName
        var name = firstName + " " + lastName
        name = name.trimmingLeadingAndTrailingSpaces()
        
    switch contactProperty.key {
    case CNContactPhoneNumbersKey:
        
    viewController?.dismiss(animated: true, completion: nil)
    if let phoneNo = contactProperty.value as? CNPhoneNumber {
        if validateName(name: name) {
            var number  = phoneNo.stringValue
            number = number.filter { ("0"..."9").contains($0) }
            if number.isValidPhoneNumber() {
                let contactPhone = Contact1(name: name, phone: number)
                let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(contactPhone)
                let jsonPhone = String(data: jsonData, encoding: String.Encoding.utf8)

                self.bridgeView.evaluate(JS: "callbackOneContact({contact :' \(String(describing: jsonPhone!))'})")

            } else {
                self.bridgeView.evaluate(JS: "callbackOneContact({contact :' \(String(describing: Constants.InvalidPhone))'})")
            }
        } else {
            self.bridgeView.evaluate(JS: "callbackOneContact({contact :' \(String(describing: Constants.InvalidName))'})")
        }

               }
    // case ...: // some other type
        
    case CNContactEmailAddressesKey:
        viewController?.dismiss(animated: true, completion: nil)
    if let contactEmailAddresses = contactProperty.contact.emailAddresses.first?.value {

        if validateName(name: name) {

            let email  = contactEmailAddresses as String

            if email.isValidEmail() {

                let contactEmail = Contact1(name: name, email: email)
                let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(contactEmail)
                let jsonEmail = String(data: jsonData, encoding: String.Encoding.utf8)
                self.bridgeView.evaluate(JS: "callbackOneContact({contact :' \(String(describing: jsonEmail!))'})")
            } else {
                self.bridgeView.evaluate(JS: "callbackOneContact({contact :' \(String(describing: Constants.InvaliEmail))'})")
            }
        } else {
            self.bridgeView.evaluate(JS: "callbackOneContact({contact :' \(String(describing: Constants.InvalidName))'})")
        }
               }

default:
    
    break
} }
    
    // CNContactPickerDelegate methods
    /*
    * This method cancels the contact details page.
    */

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
        self.bridgeView.evaluate(JS: "callbackOneContact({contact :' \("User cancelled the request")'})")
    }
}
