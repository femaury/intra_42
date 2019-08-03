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
        
        setupSearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        clustersView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        minZoomScale = UIScreen.main.bounds.width / clustersView.frame.width
        scrollView.addSubview(clustersView)
        scrollView.contentSize = clustersView.frame.size
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = 5.0
        scrollView.zoomScale = minZoomScale
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        topStackView.addArrangedSubview(activityIndicator)
        loadClusterLocations(floor: 1)
        
        segmentedControl.tintColor = API42Manager.shared.preferedPrimaryColor
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
    
    func loadClusterLocations(floor: Int) {
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
            self.clustersView.setupCluster(floor: floor, cluster: clusters)
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
    
    @objc func tapHandler(gesture: UIGestureRecognizer) {
        self.searchBar.resignFirstResponder()
    }
    
    @IBAction func clusterFloorChanged(_ sender: UISegmentedControl) {
        clustersView.clearUserImages()
        clustersView.setupCluster(floor: sender.selectedSegmentIndex + 1, cluster: clusters)
    }
    
    @IBAction func refreshClusters(_ sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItems![0].isEnabled = false
        clustersView.clearUserImages()
        loadClusterLocations(floor: segmentedControl.selectedSegmentIndex + 1)
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

extension ClustersViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            performSegue(withIdentifier: "SearchResultsSegue", sender: self)
        }
        searchBar.resignFirstResponder()
    }
}
