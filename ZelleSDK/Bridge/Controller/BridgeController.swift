//
//  BridgeController.swift
//  Fiserv
//
//  Created by omar.ata on 4/21/21.
//

import UIKit

internal class BridgeController: UIViewController {
    
/*
 *Bridgeview controller takes the values  from bridgeconfig and forms the complete url and loads in the webview.
 */
    /*
     
     
     IGNORE THIS CLASS!
     
     
     ███   ████  █   █   ███   ████   █████
      █   █      ██  █  █   █  █   █  █
      █   █  ██  █ █ █  █   █  ████   █████
      █   █   █  █  ██  █   █  █  █   █
     ███   ███   █   █   ███   █   █  █████
     
     
     █████  █   █  ███   ████
       █    █   █   █   █
       █    █████   █    ███
       █    █   █   █       █
       █    █   █  ███  ████
     
     
      ████  █        █     ████   ████
     █      █       █ █   █      █
     █      █       ███    ███    ███
     █      █      █   █      █      █
      ████  █████  █   █  ████   ████
     
     
     */
    
    public var config: BridgeConfig!
    lazy var bridgeView: BridgeView = { BridgeView(frame: view.frame, config: config, viewController: self) }()
    
    public override func viewDidLoad() {
        bridgeView.viewController = self
        view.addSubview(bridgeView)

        bridgeView.translatesAutoresizingMaskIntoConstraints = false
        bridgeView.leadingAnchor .constraint(equalTo: view.layoutMarginsGuide.leadingAnchor) .isActive = true
        bridgeView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        bridgeView.topAnchor     .constraint(equalTo: view.layoutMarginsGuide.topAnchor)     .isActive = true
        bridgeView.bottomAnchor  .constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)  .isActive = true
        
        bridgeView.load()
    }
}
