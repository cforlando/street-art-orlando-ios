//
//  ErrorView.swift
//  StreetArt
//
//  Created by Axel Rivera on 5/30/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class ErrorView: UIView {

    var titleLabel: UILabel!

    var text: String!

    init(frame: CGRect, text: String?) {
        super.init(frame: frame)

        self.backgroundColor = Color.errorBackground

        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = Color.text

        titleLabel.text = text

        self.addSubview(titleLabel)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

// MARK: - Methods

extension ErrorView {

    func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview().offset(-15.0)
        }
    }

}
