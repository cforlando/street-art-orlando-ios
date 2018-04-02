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

    let CellIdentifier = "Cell"
    let LoadingIdentifier = "Loading"

    var collectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout!

    var dataSource = ContentSectionArray()
    var submissions = SubmissionArray()

    var isFetching = false

    var page: Int = 1

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

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)

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

        collectionView.refreshControl = refreshControl

        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: CellIdentifier)

        collectionView.register(LoadingSubmissionsView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: LoadingIdentifier
        )

        self.view.addSubview(collectionView)

        // AutoLayout

        collectionView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -

extension MainViewController {

    func updateDataSource(submissionsToAdd: SubmissionArray? = nil) {
        var content: ContentRow!

        if let submissionsToAdd = submissionsToAdd {
            guard var section = dataSource.first else {
                return
            }

            var rows = section.rows

            for submission in submissionsToAdd {
                content = ContentRow(object: submission)
                content.identifier = CellIdentifier

                rows.append(content)
            }

            section.rows = rows
            dataSource = [section]
        } else {
            var rows = ContentRowArray()
            var sections = ContentSectionArray()

            for submission in submissions {
                content = ContentRow(object: submission)
                content.identifier = CellIdentifier

                rows.append(content)
            }

            sections.append(ContentSection(title: nil, rows: rows))
            dataSource = sections
        }

        collectionView.reloadData()
    }

    func reloadSubmissions() {
        if isFetching {
            return
        }

        isFetching = true

        ApiClient.shared.fetchSubmissions(page: page) { [unowned self] (result) in
            self.isFetching = false

            switch result {
            case .success(let submissions):
                if self.page == 1 && submissions.isEmpty {
                    self.submissions = submissions
                    self.updateDataSource()
                    return
                }

                var submissionsToAdd: SubmissionArray?
                if self.page == 1 {
                    self.submissions = submissions
                } else {
                    self.submissions += submissions
                    submissionsToAdd = submissions
                }

                if !submissions.isEmpty {
                    self.page += 1
                    self.updateDataSource(submissionsToAdd: submissionsToAdd)
                }
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

    @objc func addAction(_ sender: AnyObject?) {
        guard isCameraAvailable() || isPhotoLibraryAvailable() else {
            let alertView = UIAlertController(title: PHOTOS_NOT_SUPPORTED_ALERT, message: nil, preferredStyle: .alert)

            let okAction = UIAlertAction(title: OK_TEXT, style: .cancel, handler: nil)
            alertView.addAction(okAction)

            self.navigationController?.present(alertView, animated: true, completion: nil)
            return
        }

        let controller = AddViewController()

        controller.completionBlock = { [weak self] in
            guard let _ = self else {
                return
            }

           self?.navigationController?.dismiss(animated: true, completion: nil)
        }

        controller.cancelBlock = { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }

        let navController = UINavigationController(rootViewController: controller)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }

    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        page = 1
        refreshControl.endRefreshing()
        reloadSubmissions()
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

            cell.set(submission: row.object as? Submission)

            return cell
        }

        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let loadingView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionFooter,
            withReuseIdentifier: LoadingIdentifier,
            for: indexPath
        )

        return loadingView
    }

}

// MARK: UICollectionViewDelegate Methods

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier ?? String()

        switch identifier {
        case CellIdentifier:
            guard let submission = row.object as? Submission else {
                return
            }

            let controller = PhotoViewController(submission: submission)
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 34.0)
    }

}

// MARK: - UIScrollViewDelegate Methods

extension MainViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentSize.height - scrollView.frame.size.height

        dLog("y: \(scrollView.contentOffset.y), offset: \(round(offset))")

        if scrollView.contentOffset.y >= round(offset) {
            reloadSubmissions()
        }
    }

}

