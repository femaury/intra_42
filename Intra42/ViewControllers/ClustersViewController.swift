//
//  ClustersViewController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SwiftyJSON

class ClustersViewController: UIViewController {
    
    private let availableCampusIDs = [1]
    let noClusterLabel = UILabel()
    let noClusterView = UIView()
    
    var selectedCampus: (id: Int, name: String) = (0, "") //Campus
    var selectedCell: UserProfileCell?
    var floorOneCount: Int = 0 // Max: 271
    var floorOneFriends: Int = 0
    var floorTwoCount: Int = 0 // Max: 270
    var floorTwoFriends: Int = 0
    var floorThreeCount: Int = 0 // Max: 270
    var floorThreeFriends: Int = 0
    var minZoomScale: CGFloat = 0.5
    
    lazy var clusters: [String: ClusterPerson] = [:]
    lazy var searchBar = UISearchBar()
    lazy var clustersView = ClustersView(frame: CGRect(x: 0, y: 0, width: 985, height: 755))
    lazy var activityIndicator = UIActivityIndicatorView(style: .gray)
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var topStackView: UIStackView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var floorOneFriendsLabel: UILabel!
    @IBOutlet weak var floorOneUsers: UIView!
    @IBOutlet weak var floorOneUsersProgress: UIView!
    @IBOutlet weak var floorOneUsersLabel: UILabel!
    
    @IBOutlet weak var floorTwoFriendsLabel: UILabel!
    @IBOutlet weak var floorTwoUsers: UIView!
    @IBOutlet weak var floorTwoUsersProgress: UIView!
    @IBOutlet weak var floorTwoUsersLabel: UILabel!

    @IBOutlet weak var floorThreeFriendsLabel: UILabel!
    @IBOutlet weak var floorThreeUsers: UIView!
    @IBOutlet weak var floorThreeUsersProgress: UIView!
    @IBOutlet weak var floorThreeUsersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noClusterView.backgroundColor = .white
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            
            noClusterView.backgroundColor = .systemBackground
        }
        
        noClusterView.frame = view.frame
        noClusterLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width - 40, height: 200)
        noClusterLabel.text = "Sorry, this campus' map is not available yet... Feel free to open an issue on github to help speed up the process!"
        noClusterLabel.textAlignment = .center
        noClusterLabel.numberOfLines = 0
        noClusterView.addSubview(noClusterLabel)
        noClusterLabel.center = noClusterView.convert(noClusterView.center, from: noClusterLabel)
        view.addSubview(noClusterView)
        
        if let id = API42Manager.shared.userProfile?.mainCampusId, let name = API42Manager.shared.userProfile?.mainCampusName {
            selectedCampus = (id, name)
            navigationItem.title = name
            noClusterView.isHidden = availableCampusIDs.contains(id)
        } else {
            noClusterView.isHidden = true
            activityIndicator.startAnimating()
            API42Manager.shared.userProfileCompletionHandler.append({ userProfile in
                if let id = userProfile?.mainCampusId, let name = userProfile?.mainCampusName {
                    self.selectedCampus = (id, name)
                    self.navigationItem.title = name
                    self.noClusterView.isHidden = self.availableCampusIDs.contains(id)
                } else {
                    self.noClusterView.isHidden = false
                }
                self.activityIndicator.stopAnimating()
            })
        }
        
        campusLabel.isHidden = true
//        setupSearchBar()
//        searchBar.delegate = self
//        navigationItem.titleView = searchBar
        
        clustersView.delegate = self
        clustersView.clearUserImages()
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
//        tapGesture.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapGesture)

        minZoomScale = UIScreen.main.bounds.width / clustersView.frame.width
        scrollView.addSubview(clustersView)
        scrollView.contentSize = clustersView.frame.size
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = 5.0
        scrollView.zoomScale = minZoomScale
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        }
        topStackView.addArrangedSubview(activityIndicator)
        loadClusterLocations()
        
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = API42Manager.shared.preferedPrimaryColor
        } else {
            segmentedControl.tintColor = API42Manager.shared.preferedPrimaryColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControl.tintColor = API42Manager.shared.preferedPrimaryColor
        floorOneUsers.layer.borderColor = API42Manager.shared.preferedPrimaryColor?.cgColor
        floorTwoUsers.layer.borderColor = API42Manager.shared.preferedPrimaryColor?.cgColor
        floorThreeUsers.layer.borderColor = API42Manager.shared.preferedPrimaryColor?.cgColor
        floorOneUsersProgress.backgroundColor = API42Manager.shared.preferedPrimaryColor
        floorTwoUsersProgress.backgroundColor = API42Manager.shared.preferedPrimaryColor
        floorThreeUsersProgress.backgroundColor = API42Manager.shared.preferedPrimaryColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func loadClusterLocations() {
        API42Manager.shared.getLocations(forCampusId: 1, page: 1) { (data) in
            var clusters: [String: ClusterPerson] = [:]
            self.floorOneCount = 0
            self.floorOneFriends = 0
            self.floorTwoCount = 0
            self.floorTwoFriends = 0
            self.floorThreeCount = 0
            self.floorThreeFriends = 0
            
            for location in data {
                let host = location["host"].stringValue
                let name = location["user"]["login"].stringValue
                let id = location["user"]["id"].intValue
                
                if host.contains("e1") {
                    self.floorOneCount += 1
                    if FriendDataManager.shared.hasFriend(withId: id) { self.floorOneFriends += 1 }
                } else if host.contains("e2") {
                    self.floorTwoCount += 1
                    if FriendDataManager.shared.hasFriend(withId: id) { self.floorTwoFriends += 1 }
                } else if host.contains("e3") {
                    self.floorThreeCount += 1
                    if FriendDataManager.shared.hasFriend(withId: id) { self.floorThreeFriends += 1 }
                } else {
                    continue
                }
                
                clusters.updateValue(ClusterPerson(id: id, name: name), forKey: host)
            }
            self.clusters = clusters
            self.clustersView.setupCluster(floor: self.segmentedControl.selectedSegmentIndex + 1, cluster: clusters)
            self.setupClusterInfo()
            self.navigationItem.rightBarButtonItems![0].isEnabled = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setupClusterInfo() {
        let floorOneString = "\(floorOneFriends) friend\(floorOneFriends == 1 ? "" : "s")"
        floorOneFriendsLabel.text = floorOneString
        let floorTwoString = "\(floorTwoFriends) friend\(floorTwoFriends == 1 ? "" : "s")"
        floorTwoFriendsLabel.text = floorTwoString
        let floorThreeString = "\(floorThreeFriends) friend\(floorThreeFriends == 1 ? "" : "s")"
        floorThreeFriendsLabel.text = floorThreeString
        
        let floorOneTotal = "\(floorOneCount)/271"
        floorOneUsersLabel.text = floorOneTotal
        let floorTwoTotal = "\(floorTwoCount)/270"
        floorTwoUsersLabel.text = floorTwoTotal
        let floorThreeTotal = "\(floorThreeCount)/270"
        floorThreeUsersLabel.text = floorThreeTotal
        
        setClusterOccupancy(backBar: floorOneUsers, progressBar: floorOneUsersProgress, users: floorOneCount)
        setClusterOccupancy(backBar: floorTwoUsers, progressBar: floorTwoUsersProgress, users: floorTwoCount)
        setClusterOccupancy(backBar: floorThreeUsers, progressBar: floorThreeUsersProgress, users: floorThreeCount)
    }
    
    func setClusterOccupancy(backBar: UIView, progressBar: UIView, users: Int) {
        let percentage = Double(users) / 271.0
        let progress = percentage * Double(backBar.frame.width)
        progressBar.frame = CGRect(x: 0, y: 0, width: progress, height: Double(backBar.frame.height))
        progressBar.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
        progressBar.backgroundColor = API42Manager.shared.preferedPrimaryColor
        backBar.layer.cornerRadius = 5.0
        backBar.layer.borderWidth = 1.0
        backBar.layer.borderColor = API42Manager.shared.preferedPrimaryColor?.cgColor
    }
    
//    @objc func tapHandler(gesture: UIGestureRecognizer) {
//        self.searchBar.resignFirstResponder()
//    }
    
    @IBAction func clusterFloorChanged(_ sender: UISegmentedControl) {
        clustersView.clearUserImages()
        clustersView.setupCluster(floor: sender.selectedSegmentIndex + 1, cluster: clusters)
    }
    
    func refreshClusters() {
        guard availableCampusIDs.contains(selectedCampus.id) else { return }
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItems![0].isEnabled = false
        clustersView.clearUserImages()
        loadClusterLocations()
    }
    
    @IBAction func showOptions(_ sender: Any) {
        let optionsAction = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        let changeCampus = UIAlertAction(title: "Change campus", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            let campusController = TablePickerController()
            campusController.modalPresentationStyle = .fullScreen
            campusController.delegate = self
            campusController.selectedItem = self.selectedCampus
            campusController.dataSource = API42Manager.shared.getAllCampus
            _ = campusController.view
            self.navigationController?.pushViewController(campusController, animated: true)
        }
        let refresh = UIAlertAction(title: "Refresh", style: .destructive) { [weak self] (_) in
            self?.refreshClusters()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        optionsAction.addAction(changeCampus)
        optionsAction.addAction(refresh)
        optionsAction.addAction(cancel)
        present(optionsAction, animated: true, completion: nil)
    }
}

// MARK: - Prepare for segue

extension ClustersViewController: UserProfileDataSource, SearchResultsDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegue" {
            if let destination = segue.destination as? SearchResultsController {
                showSearchResultsController(atDestination: destination)
            }
        } else if segue.identifier == "UserProfileSegue" {
            if let destination = segue.destination as? UserProfileController {
                showUserProfileController(atDestination: destination)
            }
        }
    }
}

// MARK: - Table Picker Delegate

extension ClustersViewController: TablePickerDelegate {
    
    func selectItem(_ item: TablePickerItem) {
        selectedCampus = item
        navigationItem.title = item.name
        noClusterView.isHidden = availableCampusIDs.contains(item.id)
        noClusterLabel.text = "Sorry, this campus' map is not available yet... Feel free to open an issue on github to help speed up the process!"
    }
}

// MARK: - Scroll View Delegate

extension ClustersViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return clustersView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        infoView.isHidden = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == minZoomScale {
            infoView.isHidden = false
        }
    }
}

// MARK: - Search Bar Delegate

//extension ClustersViewController: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if searchBar.text != nil {
//            performSegue(withIdentifier: "SearchResultsSegue", sender: self)
//        }
//        searchBar.resignFirstResponder()
//    }
//}
