//
//  Zelle.swift
//  BridgeSDK
//
//  Created by omar.ata on 5/26/21.
//

import UIKit

public class Zelle: BridgeConfig {
    public var url: String
    public var preCacheContacts = false
    
    // Original Instance
    
    public init(
        institutionId: String,
        ssoKey: String,
        title : String,
        parameters: [String:String]
    ) {
        UserDefaults.standard.set(title, forKey: "title")
        url = "https://jayjt11.github.io/Sdk/index.html"
        url += "?institutionId=\(institutionId)&key=\(ssoKey)"
        for param in parameters {
            url += "&\(param.key)=\(param.value)"
        }
    }
    
    
    // Url construction
    
//    public init(
//        baseUrl :String,
//        institutionId: String,
//        product: String,
//        ssoKey: String,
//        title : String,
//        parameters: [String:String]
//    ) {
//        UserDefaults.standard.set(title, forKey: "title")
//        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
//        url = baseUrl
//        url += "?institutionId=\(institutionId)&product=\(product)&container=zelle_sdk_ios&version=\(version)&key=\(ssoKey)"
//        for param in parameters {
//            url += "&\(param.key)=\(param.value)"
//
//        }
//
//        print("Url is \(url)")
//   }
}
