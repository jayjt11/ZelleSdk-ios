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
}
