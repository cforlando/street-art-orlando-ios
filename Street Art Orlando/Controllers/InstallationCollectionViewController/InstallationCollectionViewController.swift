//
//  InstallationCollectionViewController.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/4/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

private struct Constants {
    static let cellReuseIdentifier = "InstallationCell"
    
    struct menuLabels {
        static let licenses = "Licenses"
        static let signOut = "Sign Out"
        static let cancel = "Cancel"
    }
    
    static let menuImage = "VerticalEllipsis"
  
  struct segues {
    static let detail = "InstallationDetail"
    static let menu = "ShowCornerMenu"
    static let license = "ShowLicenseInfo"
  }
}

class InstallationCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.themeColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Constants.segues.detail:
            if let detailViewController = segue.destination as? InstallationDetailViewController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                
                if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                    detailViewController.installation = SampleData.dataSource[indexPath.row]
                }
            }
            
        case Constants.segues.menu:
            if let menuViewController = segue.destination as? CornerMenuViewController {
                menuViewController.transitioningDelegate = menuViewController
                menuViewController.action = {
                    [unowned self] (action) in
                    
                    switch action {
                    case .license:
                        self.dismiss(animated: true) {
                            self.performSegue(withIdentifier: Constants.segues.license, sender: nil)
                        }
                        break
                        
                    case .signOut:
                        self.dismiss(animated: true) {
                            if let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignIn") {
                                (UIApplication.shared.delegate as! AppDelegate).switchToViewController(viewController: mainViewController)
                            }

                        }
                        break
                    }
                }
            }
            
        default:
            break;
        }
        
        guard segue.identifier == Constants.segues.detail else { return }
        
        if let detailViewController = segue.destination as? InstallationDetailViewController {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                detailViewController.installation = SampleData.dataSource[indexPath.row]
            }
        }
    }
}

extension InstallationCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SampleData.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath) as! InstallationCollectionViewCell
        
        let installation = SampleData.dataSource[indexPath.row]
        
        
        cell.imageView.image = installation.primaryImage
        cell.locationLabel.text = installation.location.locationName
        
        return cell
    }
}

private struct LayoutMetrics {
    static let margin : CGFloat = 8
    static let spacing : CGFloat = 8
    
    static var leftMargin : CGFloat {
        return margin
    }
    
    static var rightMargin : CGFloat {
        return margin
    }

    static var topMargin : CGFloat {
        return margin
    }

    static var bottomMargin : CGFloat {
        return margin
    }

    static var sectionInsets : UIEdgeInsets {
        return UIEdgeInsets(
            top: LayoutMetrics.topMargin,
            left: LayoutMetrics.leftMargin,
            bottom: LayoutMetrics.bottomMargin,
            right: LayoutMetrics.rightMargin
        )
    }
    
    static func cellSize(_ view: UICollectionView) -> CGSize {
        let width = (view.bounds.width - LayoutMetrics.leftMargin - LayoutMetrics.rightMargin - LayoutMetrics.spacing) / 2
        
        return CGSize(width: width, height: width)
    }
}

extension InstallationCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return LayoutMetrics.cellSize(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return LayoutMetrics.spacing
    }
}
