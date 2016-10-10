//
//  CornerMenuView.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/10/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

class CornerMenuViewControllerX: UIViewController {
    static var presentationWindow: UIWindow?
    
    class func presentMenu() {
        presentationWindow = UIWindow()
        if let keyWindow = UIApplication.shared.keyWindow {
            
            presentationWindow?.isOpaque = false
            presentationWindow?.backgroundColor = UIColor.clear
//            presentationWindow!.frame = keyWindow.bounds
            
            let menuViewController = CornerMenuViewController(nibName: "CornerMenuView", bundle: nil)
            
            keyWindow.rootViewController = menuViewController
    
            keyWindow.makeKeyAndVisible()
            // create a window
            // add subview to window
            // make window the key window
            
        }
    }
    

}
