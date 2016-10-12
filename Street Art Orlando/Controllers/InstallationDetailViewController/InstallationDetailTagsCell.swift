//
//  InstallationDetailTagsCell.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/6/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

class InstallationDetailTagsCell: UITableViewCell {

    @IBOutlet weak var tagsView: TagStackView!
    
    func configure(withInstallation installation: ArtInstallation) {
        tagsView.tags = installation.separatedTagsString()
    }
}
