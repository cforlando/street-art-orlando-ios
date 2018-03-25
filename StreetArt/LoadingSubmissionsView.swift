//
//  LoadingSubmissionsView.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/24/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class LoadingSubmissionsView: UICollectionReusableView {

    var loadingView: UIActivityIndicatorView!

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        loadingView = UIActivityIndicatorView()
        loadingView.activityIndicatorViewStyle = .gray
        loadingView.startAnimating()

        self.addSubview(loadingView)

        // AutoLayout

        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
