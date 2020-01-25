//
//  PeerResultsController.swift
//  Intra42
//
//  Created by Felix Maury on 15/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class PeerResultsController: UITableViewController, UserProfileDataSource {

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let searchController = UISearchController(searchResultsController: nil)
    
    var controllerId: String = ""
    var isLoading: Bool = true
    var offlineUsers: [ProjectUser] = []
    var onlineUsers: [ProjectUser] = []
    var totalUsers: [ProjectUser] {
        return onlineUsers + offlineUsers
    }
    
    var filteredOfflineUsers: [ProjectUser] = []
    var filteredOnlineUsers: [ProjectUser] = []
    var filteredTotalUsers: [ProjectUser] {
        return filteredOnlineUsers + filteredOfflineUsers
    }
    
    var selectedCell: UserProfileCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keeps navbar background color black in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }

        self.navigationItem.titleView = activityIndicator
        activityIndicator.hidesWhenStopped = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func loadProjectUsers(forProjectId id: Int, campusId: Int, filter: PeerFinderViewController.Filter) {
        controllerId = "\(id)\(campusId)\(filter)"
        
        API42Manager.shared.getProjectUsers(forProjectId: id, campusId: campusId, filter: filter) { [weak self] (projectUsers, finished) in
            guard let self = self else { return false }
            self.onlineUsers = projectUsers.filter { $0.location != "Unavailable" }.sorted { $0.grade ?? 0 > $1.grade ?? 0}
            self.offlineUsers = projectUsers.filter { $0.location == "Unavailable" }.sorted { $0.grade ?? 0 > $1.grade ?? 0}
            self.isLoading = false
            self.tableView.reloadData()
            if finished {
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.startAnimating()
            }
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserProfileSegue" {
            if let destination = segue.destination as? UserProfileController {
                showUserProfileController(atDestination: destination)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !totalUsers.isEmpty else { return 1 }
        let count = isFiltering() ? filteredTotalUsers.count : totalUsers.count
        return count > 150 ? 150 : count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return totalUsers.isEmpty ? tableView.frame.height : 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ProjectUserCell else { return }
        selectedCell = cell
        performSegue(withIdentifier: "UserProfileSegue", sender: self)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell")
                ?? UITableViewCell(style: .default, reuseIdentifier: "loadingCell")
            let activity = UIActivityIndicatorView(frame: tableView.frame)
            if #available(iOS 13.0, *) {
                activity.style = .large
            }
            activity.hidesWhenStopped = true
            activity.startAnimating()
            cell.contentView.addSubview(activity)
            return cell
        }
        if totalUsers.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "loadingCell")
            cell.textLabel?.text = "Looks like you're alone on this one, partner..."
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            cell.frame = tableView.frame
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectUserCell", for: indexPath) as! ProjectUserCell
        cell.user = isFiltering() ? filteredTotalUsers[indexPath.row] : totalUsers[indexPath.row]
        return cell
    }
}

// MARK: - Search Results Updating
extension PeerResultsController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let searchText = searchBar.text {
            filteredOnlineUsers = onlineUsers.filter({ (item) -> Bool in
                return item.login.lowercased().contains(searchText.lowercased())
            })
            filteredOfflineUsers = offlineUsers.filter({ (item) -> Bool in
                return item.login.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}
