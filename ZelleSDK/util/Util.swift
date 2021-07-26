//
//  Util.swift
//  ZelleSDK
//
//  Created by Jayant Tiwari on 05/07/21.
//  Copyright © 2021 Fiserv. All rights reserved.
//

import UIKit
import Foundation

class Util {
    
    // convert to base64
    static func convertImageToBase64String (img: UIImage) -> String {
                let imageData:NSData = img.jpegData(compressionQuality: 0.20)! as NSData //UIImagePNGRepresentation(img)
                let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
                return imgString
    }
}

extension String {
    
    var isAlphanumericDashUnderscore: Bool {
        get {
            let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9_-]$@", options: .caseInsensitive)
            let isAlphaNumeric = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
            return isAlphaNumeric
        }
    }
}

extension String {

    func isValidPhoneNumber() -> Bool {

        let number = self
        let digit = number.filter { ("0"..."9").contains($0) }
        let pattern = try! NSRegularExpression(pattern: "[0-9\\.\\-\\+\\,\\(\\)\\ ]+", options: .caseInsensitive)
        if ((pattern.firstMatch(in: number, options: [], range: NSRange(location: 0, length: count)) != nil) == false) {
            return false
        }
        else if (digit.count == 11 && digit.hasPrefix("1")) {

            let number1 = digit
            let number2 = String(number1.dropFirst())
            let phoneNumberRegex = "^(?!0|1|000|800|844|855|866|877|888)\\d{10}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
            let isValidPhone = phoneTest.evaluate(with: number2)
            return isValidPhone
            
        } else if (digit.count == 10) {
            let number1 = digit
            let phoneNumberRegex = "^(?!0|1|000|800|844|855|866|877|888)\\d{10}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
            let isValidPhone = phoneTest.evaluate(with: number1)
            return isValidPhone
        }
        else {
           return false
        }
    }
}

extension String {
    
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

extension String {
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
