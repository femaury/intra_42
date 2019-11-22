//
//  AchievementsController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-20.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class AchievementsController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)

    var achievements: [String: Achievement] = [:]
    var achievementsIndices: [String] = []
    var filteredIndices: [String] = []
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fixes navbar color bug when extended for search controller
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search achievements..."
        searchController.searchBar.scopeButtonTitles = ["All",
                                                        "Bronze",
                                                        "Silver",
                                                        "Gold",
                                                        "Platinum"]
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        let ownedSortingClosure = { (this: String, that: String) -> Bool in
            if let userAchievements = API42Manager.shared.userProfile?.achievements {
                if userAchievements[this] != nil {
                    return true
                }
            }
            return false
        }
        
        if API42Manager.shared.allAchievements.count > 0 {
            self.achievements = API42Manager.shared.allAchievements
            self.achievementsIndices = self.achievements.keys.sorted(by: ownedSortingClosure)
            self.isLoading = false
        } else {
            API42Manager.shared.getAllAchievements { (achievements) in
                self.achievements = achievements
                self.achievementsIndices = achievements.keys.sorted(by: ownedSortingClosure)
                self.isLoading = false
                self.tableView.reloadData()
            }
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    @objc func refreshTable() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
}

// MARK: - Search Controller

extension AchievementsController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let searchText = searchBar.text {
            if let scope = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] {
                filterEvents(forSearch: searchText, scope: scope)
            } else {
                filterEvents(forSearch: searchText)
            }
        }
    }
    
    func filterEvents(forSearch search: String, scope: String = "All") {
        filteredIndices = achievementsIndices.filter({ (name) -> Bool in
            guard let achievement = API42Manager.shared.userProfile?.achievements[name] ?? achievements[name] else {
                return false
            }
            var tier: AchievementTier = .none
            switch scope {
            case "Bronze":
                tier = .easy
            case "Silver":
                tier = .medium
            case "Gold":
                tier = .hard
            case "Platinum":
                tier = .challenge
            default:
                tier = .none
            }
            let match = scope == "All" || achievement.tier == tier
            if self.searchBarIsEmpty() {
                return match
            } else {
                return match && name.lowercased().contains(search.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let search = searchBar.text, let scope = searchBar.scopeButtonTitles?[selectedScope] {
            filterEvents(forSearch: search, scope: scope)
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

// MARK: - Table View Delegate

extension AchievementsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLoading || isFiltering() {
            return 0
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !isLoading, !isFiltering() else { return nil }
        let header = tableView.dequeueReusableCell(withIdentifier: "AchievementsHeaderCell") as! AchievementsHeaderCell
        header.achievementCount = API42Manager.shared.userProfile?.achievementsCount
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        }
        if isFiltering() {
            return filteredIndices.count
        }
        return achievementsIndices.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoading {
            return tableView.frame.height
        }
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingIndicatorCell")!
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementCell") as! AchievementCell
        var index = achievementsIndices[indexPath.row]
        if isFiltering() {
            index = filteredIndices[indexPath.row]
        }
        if let achievement = achievements[index] {
            cell.isOwned = false
            cell.achievement = achievement
            cell.containerView.alpha = 0.4
            if let userAchievements = API42Manager.shared.userProfile?.achievements {
                if let userAchievement = userAchievements[achievement.name] {
                    cell.isOwned = true
                    cell.achievement = userAchievement
                    cell.containerView.alpha = 1.0
                }
            }
        }
        return cell
    }
}
