//
//  AgreementCell.swift
//  StreetArt
//
//  Created by Axel Rivera on 10/7/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

protocol AgreementCellDelegate: AnyObject {

    func didChangeAgreement(cell: UITableViewCell, value: Bool)

}

class AgreementCell: UITableViewCell {

    struct Constants {
        static let height: CGFloat = 44.0
    }

    static var defaultHeight = Constants.height

    var titleLabel: UILabel!
    var agreementSwitch: UISwitch!

    weak var agreementDelegate: AgreementCellDelegate?

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.minimumScaleFactor = 12.0 / 16.0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = Color.highlight
        titleLabel.textAlignment = .left
        titleLabel.text = REGISTER_TERM_AGREE_TITLE

        self.contentView.addSubview(titleLabel)

        agreementSwitch = UISwitch()
        agreementSwitch.isOn = false
        agreementSwitch.addTarget(self, action: #selector(agreementSwitchAction(_:)), for: .valueChanged)

        self.contentView.addSubview(agreementSwitch)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: - Methods

extension AgreementCell {

    func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15.0)
            make.right.equalTo(agreementSwitch.snp.left).offset(-15.0)
        }

        agreementSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.contentView.snp.rightMargin)
        }
    }

}

// MARK: - Selector Methods

extension AgreementCell {

    @objc func agreementSwitchAction(_ agreementSwitch: UISwitch) {
        if let delegate = self.agreementDelegate {
            delegate.didChangeAgreement(cell: self, value: agreementSwitch.isOn)
        }
    }

}
