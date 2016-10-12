//
//  InstallationDetailNearbyArtCell.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/6/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit


class InstallationDetailNearbyArtCell: UITableViewCell {
    var nearbyArt = ["1", "2", "3", "4", "5", "6", "7"]

}

extension InstallationDetailNearbyArtCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyArt.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NearbyArtCollectionViewCell",
            for: indexPath
            ) as! NearbyArtCollectionViewCell
        
        let imageName = nearbyArt[indexPath.row]
        if let image = UIImage(named: imageName) {
            cell.imageView.image = image
        }
        
        return cell
    }
}

extension InstallationDetailNearbyArtCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height * 1.2, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}











