//
//  MainViewController.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import PKHUD

class MainViewController: UIViewController {

    struct Constants {
        static let spacing: CGFloat = 4.0
    }

    struct GroupIdentifier {
        static let cell = "CellIdentifier"
        static let loading = "LoadingCell"
    }

    var refreshControl: UIRefreshControl!

    var collectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout!

    var submissions = SubmissionArray()

    var isFetching = false

    var nextPage: Int = 1
    var isLastPage = false

    var shouldSetupLayout = true

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = MAIN_TITLE
        self.tabBarItem = UITabBarItem(title: MAIN_TAB, image: #imageLiteral(resourceName: "explore_tab"), tag: 0)
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

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: BACK_TEXT, style: .plain, target: nil, action: nil)

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
        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView.refreshControl = refreshControl

        collectionView.register(ContentCell.self, forCellWithReuseIdentifier: GroupIdentifier.cell)

        collectionView.register(
            LoadingSubmissionsView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: GroupIdentifier.loading
        )

        self.view.addSubview(collectionView)

        // AutoLayout

        collectionView.snp.makeConstraints { (make) in
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


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if shouldSetupLayout {
            var collectionInset = collectionView.contentInset
            collectionInset.bottom = self.view.safeAreaInsets.bottom

            collectionView.contentInset = collectionInset
            collectionView.scrollIndicatorInsets = collectionInset

            shouldSetupLayout = false
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

extension MainViewController {

    func reloadSubmissions(reset: Bool = false, showHud: Bool = false) {
        if reset {
            nextPage = 1
            isLastPage = false
        }

        if isLastPage {
            return
        }

        if isFetching {
            return
        }

        isFetching = true

        if showHud && self.isViewLoaded {
            HUD.show(.progress, onView: self.view)
        }

        ApiClient.shared.submissions(page: nextPage) { [unowned self] (result) in
            self.isFetching = false

            if let refreshControl = self.collectionView.refreshControl, refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }

            if HUD.isVisible {
                HUD.hide()
            }

            switch result {
            case .success(let container):
                if reset {
                    self.submissions = SubmissionArray()
                }

                self.isLastPage = container.nextPage == nil
                self.nextPage = container.nextPage ?? container.currentPage

                self.submissions += container.submissions
                self.collectionView.reloadData()
            case .failure:
                let alertController = UIAlertController(title: LOADING_ERROR_TITLE, message: LOADING_ERROR_MESSAGE, preferredStyle: .alert)

                let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
                alertController.addAction(okAction)

                self.navigationController?.present(alertController, animated: true, completion: nil)
            }
        }
    }

}

// MARK: Selector Methods

extension MainViewController {

    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        reloadSubmissions(reset: true)
    }

    @objc func favoriteUpdatedAction(_ notification: Notification) {
        guard let favorite = notification.userInfo?[Keys.favorite] as? Submission else {
            return
        }

        if let index = submissions.index(of: favorite) {
            submissions[index] = favorite
            collectionView.reloadData()
        }
    }

}

// MARK: - Collection View Methods
// MARK: UICollectionViewDataSource Methods

extension MainViewController: UICollectionViewDataSource {

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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let loadingView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: GroupIdentifier.loading,
            for: indexPath
        ) as! LoadingSubmissionsView

        if isLastPage {
            loadingView.loadingView.stopAnimating()
        } else {
            if !submissions.isEmpty {
                loadingView.loadingView.startAnimating()
            }
        }

        return loadingView
    }

}

// MARK: UICollectionViewDelegate Methods

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let submission = submissions[indexPath.row]

        let controller = PhotoViewController(submission: submission)
        controller.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(controller, animated: true)
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 34.0)
    }

}

// MARK: - UIScrollViewDelegate Methods

extension MainViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isLastPage {
            return
        }

        let offset = scrollView.contentSize.height - scrollView.frame.size.height
        if scrollView.contentOffset.y >= round(offset) {
            reloadSubmissions()
        }
    }

}

