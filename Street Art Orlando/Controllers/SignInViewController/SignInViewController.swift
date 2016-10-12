//
//  SignInViewController.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/10/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBAction func signIn(_ sender: UIButton) {
        if let mainViewController = storyboard?.instantiateViewController(withIdentifier: "StreetArtCollectionNavController") {
            (UIApplication.shared.delegate as! AppDelegate).switchToViewController(viewController: mainViewController)
        }
    }
}
