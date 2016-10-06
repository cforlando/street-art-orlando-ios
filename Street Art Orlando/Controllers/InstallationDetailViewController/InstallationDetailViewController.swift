//
//  InstallationDetailViewController.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/5/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

class InstallationDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailsTableView: UITableView!
//    @IBOutlet weak var nearbyArtCollectionView: UICollectionView!
    
    var installation : ArtInstallation? {
        didSet {
            refreshViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTableView.estimatedRowHeight = 120
        detailsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshViews()
    }
    
    func refreshViews() {
        guard (installation != nil) && (imageView != nil) else { return }
        
        title = installation?.location.locationName
        imageView.image = installation?.primaryImage
    }
    
    
    @IBAction func visit(_ sender: UIButton) {
    }
    
    @IBAction func like(_ sender: UIButton) {
    }
    
    @IBAction func tag(_ sender: UIButton) {
    }
}

private struct CellIdentifiers {
    static let tagsCell = "TagsCell"
    static let nearCell = "NearbyArtCell"
}

extension InstallationDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.tagsCell, for: indexPath) as! InstallationDetailTagsCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.nearCell, for: indexPath) as! InstallationDetailNearbyArtCell
            
            return cell
        }
    }
}

