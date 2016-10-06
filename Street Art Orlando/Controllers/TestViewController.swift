//
//  TestViewController.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/5/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var tagViewStack: TagStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagViewStack.layer.borderColor = UIColor.red.cgColor
        tagViewStack.layer.borderWidth = 0.5
    }    
}
