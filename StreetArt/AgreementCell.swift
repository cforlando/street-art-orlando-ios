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
    func didPressAgreementButton(cell: UITableViewCell)
}

class AgreementCell: UITableViewCell {

    struct Constants {
        static let height: CGFloat = 68.0
    }

    static var defaultHeight = Constants.height

    var titleLabel: UILabel!
    var agreementSwitch: UISwitch!
    var agreementButton: UIButton!

    weak var agreementDelegate: AgreementCellDelegate?

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.minimumScaleFactor = 12.0 / 16.0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = Color.text
        titleLabel.textAlignment = .left
        titleLabel.text = REGISTER_TERM_AGREE_TITLE

        self.contentView.addSubview(titleLabel)

        agreementSwitch = UISwitch()
        agreementSwitch.isOn = false
        agreementSwitch.addTarget(self, action: #selector(agreementSwitchAction(_:)), for: .valueChanged)

        self.contentView.addSubview(agreementSwitch)

        agreementButton = UIButton(type: .system)
        agreementButton.setTitle(REGISTER_TERM_AGREE_BUTTON_TEXT, for: .normal)
        agreementButton.addTarget(self, action: #selector(agreementButtonAction(_:)), for: .touchUpInside)

        self.contentView.addSubview(agreementButton)

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
            make.top.equalToSuperview().offset(10.0)
            make.left.equalToSuperview().offset(15.0)
            make.right.equalTo(agreementSwitch.snp.left).offset(-15.0)
        }

        agreementSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.contentView.snp.rightMargin)
        }

        agreementButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-5.0)
            make.left.equalTo(titleLabel.snp.left)
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

    @objc func agreementButtonAction(_ sender: AnyObject?) {
        if let delegate = self.agreementDelegate {
            delegate.didPressAgreementButton(cell: self)
        }
    }

}
