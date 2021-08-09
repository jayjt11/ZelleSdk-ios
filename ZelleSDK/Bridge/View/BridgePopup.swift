//
//  Fiserv
//
//  Created by omar.ata on 4/9/21.
//

import UIKit
import WebKit

public class BridgePopup: UIView, BridgeDelegate {
    
/*
* Will be shown to user as popup which will be integrated to the activity/Viewcontroller in the parent app
*/

    public lazy var bridgeView: BridgeView = { BridgeView(frame: frame, config: config, viewController: self.viewController) }()
    internal var config: BridgeConfig
    internal var viewController: UIViewController
    
    /*
    *initWithFrame to init view from code
    */
    public init(anchor: UIView, config: BridgeConfig, viewController: UIViewController) {
        self.viewController = viewController
        self.config = config
        super.init(frame: anchor.frame)
        setupView()
    }
    
    /*
    *initWithCode to init view from xib or storyboard
    */
    required init?(coder aDecoder: NSCoder) {
        config = RawConfig(url: "")
        viewController = UIViewController()
        super.init(coder: aDecoder)
        setupView()
    }

    //common func to init our view
    private func setupView() {
        //setup the black background layer
        let blackLayer = UIView(frame: frame)
        blackLayer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)

        addSubview(blackLayer)
        addSubview(bridgeView)
        bridgeView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            NSLayoutConstraint(item: blackLayer, attribute: .top,    relatedBy: .equal, toItem: self, attribute: .top,    multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blackLayer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blackLayer, attribute: .left,   relatedBy: .equal, toItem: self, attribute: .left,   multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blackLayer, attribute: .right,  relatedBy: .equal, toItem: self, attribute: .right,  multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: bridgeView, attribute: .top,    relatedBy: .equal, toItem: self, attribute: .top,    multiplier: 1, constant: 300),
            NSLayoutConstraint(item: bridgeView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bridgeView, attribute: .left,   relatedBy: .equal, toItem: self, attribute: .left,   multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bridgeView, attribute: .right,  relatedBy: .equal, toItem: self, attribute: .right,  multiplier: 1, constant: 0),
        ]
        NSLayoutConstraint.activate(constraints)
        
        addDismissHandler()
        load()
    }
    
    public func load() {
        bridgeView.load()
    }
    
    private func addDismissHandler() {
        let popupHandler = PopupHandler(bridgePopup: self)
        bridgeView.webView?.configuration.userContentController.add(popupHandler, name: "dismissPopup")
    }
}
