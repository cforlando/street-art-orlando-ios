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
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var installation : ArtInstallation? {
        didSet {
            refreshViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTableView.estimatedRowHeight = 120
        detailsTableView.rowHeight = UITableViewAutomaticDimension
        view.backgroundColor = UIColor.themeColor
        titleView.backgroundColor = UIColor.themeColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        refreshViews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func refreshViews() {
        guard (installation != nil) && (imageView != nil) else { return }
        
        titleLabel.text = installation?.location.locationName
        imageView.image = installation?.primaryImage
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func visit(_ sender: UIButton) {
    }
    
    @IBAction func like(_ sender: UIButton) {
    }
    
    @IBAction func tag(_ sender: UIButton) {
        performSegue(withIdentifier: Identifiers.addTagSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.addTagSegue {
            if let addTagViewController = segue.destination as? AddTagViewController {
                addTagViewController.transitioningDelegate = addTagViewController
                addTagViewController.addTagString = { [unowned self] (tagString) in
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

private struct Identifiers {
    static let tagsCell = "TagsCell"
    static let nearCell = "NearbyArtCell"
    
    static let addTagSegue = "AddTag"
}

extension InstallationDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.tagsCell, for: indexPath) as! InstallationDetailTagsCell

            if let installation = installation {
                cell.configure(withInstallation: installation)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.nearCell, for: indexPath) as! InstallationDetailNearbyArtCell
            
            return cell
        }
    }
}

