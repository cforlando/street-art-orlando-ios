//
//  MainViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    struct Constants {
        static let spacing: CGFloat = 4.0
    }

    let CellIdentifier = "Cell"

    var collectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout!

    var dataSource = ContentSectionArray()

    var shouldUpdateConstraints = true

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = MAIN_TITLE
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: BACK_TEXT, style: .plain, target: nil, action: nil)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addAction(_:))
        )

        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = Constants.spacing
        flowLayout.minimumInteritemSpacing = Constants.spacing

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = Color.secondary.withAlphaComponent(0.2)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.alwaysBounceVertical = true
        collectionView.isPagingEnabled = false

        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: CellIdentifier)

        self.view.addSubview(collectionView)

        updateDataSource()
    }

    override func viewWillLayoutSubviews() {
        if shouldUpdateConstraints {
            collectionView.snp.remakeConstraints { (make) in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
            shouldUpdateConstraints = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -

extension MainViewController {

    func updateDataSource() {
        var content: ContentRow!
        var rows = ContentRowArray()
        var sections = ContentSectionArray()

        for _ in 0..<25 {
            content = ContentRow(object: StreetArt.sample)
            content.identifier = CellIdentifier

            rows.append(content)
        }

        sections.append(ContentSection(title: nil, rows: rows))

        dataSource = sections
        collectionView.reloadData()
    }

}

// MARK: Selector Methods

extension MainViewController {

    @objc func addAction(_ sender: AnyObject?) {
        guard isCameraAvailable() || isPhotoLibraryAvailable() else {
            let alertView = UIAlertController(title: PHOTOS_NOT_SUPPORTED_ALERT, message: nil, preferredStyle: .alert)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(okAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
            return
        }

        let controller = AddViewController()

        controller.saveBlock = { [weak self] (streetArt) in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }

        controller.cancelBlock = { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }

        let navController = UINavigationController(rootViewController: controller)

        self.navigationController?.present(navController, animated: true, completion: nil)
    }

}

// MARK: - Collection View Methods
// MARK: UICollectionViewDataSource Methods

extension MainViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier ?? String()

        if identifier == CellIdentifier {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! PhotoCell

            cell.set(streetArt: row.object as? StreetArt)

            return cell
        }

        return UICollectionViewCell()
    }

}

// MARK: UICollectionViewDelegate Methods

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier ?? String()

        switch identifier {
        case CellIdentifier:
            guard let streetArt = row.object as? StreetArt else {
                return
            }

            let controller = PhotoViewController(streetArt: streetArt)
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

}

// MARK: UICollectionViewDelegateFlowLayout Methods

extension MainViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentWidth = collectionView.frame.size.width - (Constants.spacing * 3.0)

        let width = contentWidth / 2.0
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.spacing, left: Constants.spacing, bottom: Constants.spacing, right: Constants.spacing)
    }

}

