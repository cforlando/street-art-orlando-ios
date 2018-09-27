//
//  FavoritesViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 4/7/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class FavoritesViewController: UIViewController {

    struct Constants {
        static let spacing: CGFloat = 5.0
    }

    struct GroupIdentifier {
        static let cell = "CellIdentifier"
    }

    var refreshControl: UIRefreshControl!

    var errorView: ErrorView?

    var collectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout!

    var submissions = SubmissionArray()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = FAVORITES_TITLE
        self.tabBarItem = UITabBarItem(title: FAVORITES_TAB, image: #imageLiteral(resourceName: "favorites_tab"), tag: 1)
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

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)

        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = Constants.spacing
        flowLayout.minimumInteritemSpacing = Constants.spacing

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = Color.background
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.alwaysBounceVertical = true
        collectionView.isPagingEnabled = false

        collectionView.refreshControl = refreshControl

        collectionView.register(ContentCell.self, forCellWithReuseIdentifier: GroupIdentifier.cell)

        self.view.addSubview(collectionView)

        // AutoLayout

        collectionView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoriteUpdatedAction(_:)),
            name: .favoriteUpdated, object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !ApiClient.shared.isAuthenticated {
            submissions = SubmissionArray()
            collectionView.reloadData()

            if let errorView = self.errorView {
                errorView.removeFromSuperview()
            }

            errorView = ErrorView(frame: .zero, text: FAVORITES_LOGIN_REQUIRED_MESSAGE)
            self.view.addSubview(errorView!)

            errorView!.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
            if submissions.isEmpty {
                reloadFavorites(animated: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .favoriteUpdated, object: nil)
    }
    
}

// MARK: -
// MARK: Methods

extension FavoritesViewController {

    func reloadFavorites(animated: Bool = false) {
        if animated {
            HUD.show(.progress, onView: self.view)
        }

        ApiClient.shared.favorites { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }

            if animated {
                HUD.hide()
            }

            if weakSelf.refreshControl.isRefreshing {
                weakSelf.refreshControl.endRefreshing()
            }

            switch result {
            case .success(let submissions):
                if let errorView = weakSelf.errorView {
                    errorView.removeFromSuperview()
                }

                if submissions.isEmpty {
                    weakSelf.errorView = ErrorView(frame: .zero, text: FAVORITES_EMPTY_MESSAGE)
                    weakSelf.view.addSubview(weakSelf.errorView!)

                    weakSelf.errorView!.snp.makeConstraints { (make) in
                        make.edges.equalToSuperview()
                    }
                }

                weakSelf.submissions = submissions
                weakSelf.collectionView.reloadData()
            case .failure:
                weakSelf.errorView = ErrorView(frame: .zero, text: FAVORITES_EMPTY_MESSAGE)
                weakSelf.view.addSubview(weakSelf.errorView!)

                let alertController = UIAlertController(title: LOADING_ERROR_TITLE, message: LOADING_ERROR_MESSAGE, preferredStyle: .alert)

                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertController.addAction(okAction)

                weakSelf.navigationController?.present(alertController, animated: true, completion: nil)
            }
        }
    }

}

// MARK: Selector Methods

extension FavoritesViewController {

    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        reloadFavorites()
    }

    @objc func favoriteUpdatedAction(_ notification: Notification) {
        guard let favorite = notification.userInfo?[Keys.favorite] as? Submission else {
            return
        }

        let addFavorite = (notification.userInfo?[Keys.addFavorite] as? Bool) ?? false
        let removeFavorite = (notification.userInfo?[Keys.removeFavorite] as? Bool) ?? false

        if addFavorite {
            submissions.insert(favorite, at: 0)
            collectionView.reloadData()
        }

        if removeFavorite {
            if let index = submissions.index(of: favorite) {
                submissions.remove(at: index)
                collectionView.reloadData()
            }
        }

        if submissions.isEmpty {
            if let errorView = self.errorView {
                errorView.removeFromSuperview()
            }

            errorView = ErrorView(frame: .zero, text: FAVORITES_EMPTY_MESSAGE)
            self.view.addSubview(errorView!)

            errorView!.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
            if let errorView = self.errorView {
                errorView.removeFromSuperview()
            }
        }
    }

}

// MARK: - Collection View Methods
// MARK: UICollectionViewDataSource Methods

extension FavoritesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return submissions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIdentifier.cell, for: indexPath) as! ContentCell

        let submission = submissions[indexPath.row]
        cell.set(submission: submission)

        return cell
    }

}

// MARK: UICollectionViewDelegate Methods

extension FavoritesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let submission = submissions[indexPath.row]

        let controller = PhotoViewController(submission: submission, inFavorites: true)
        controller.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(controller, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

}

// MARK: UICollectionViewDelegateFlowLayout Methods

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = width / 2.0

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.spacing, left: 0.0, bottom: Constants.spacing, right: 0.0)
    }

}
