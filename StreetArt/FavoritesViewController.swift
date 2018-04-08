//
//  FavoritesViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/7/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = FAVORITES_TITLE
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 2)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
