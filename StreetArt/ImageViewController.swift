//
//  ImageViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 5/31/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class ImageViewController: UIViewController {

    var imageView: UIImageView!

    var image: UIImage?

    init(image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.title = PHOTO_TEXT
        self.image = image
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: DONE_TEXT,
            style: .done,
            target: self,
            action: #selector(dismissAction(_:))
        )

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = image

        self.view.addSubview(imageView)

        // AutoLayout

        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -
// MARK: - Selector Methods

extension ImageViewController {

    @objc func dismissAction(_ sender: AnyObject?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}
