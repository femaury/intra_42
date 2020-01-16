//
//  PeerListController.swift
//  Intra42
//
//  Created by Felix Maury on 07/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

enum PeerListType {
    case campus
    case cursus
    case project
}

class PeerListController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    weak var delegate: PeerFinderViewController?
    var type: PeerListType = .cursus
    var isLoading = true
    
    var campus: [(id: Int, name: String)] = []
    var filteredCampus: [(id: Int, name: String)] = []
    
    var cursus: [(id: Int, name: String)] = []
    var filteredCursus: [(id: Int, name: String)] = []
    
    var projects: [ProjectItem] = []
    var filteredProjects: [ProjectItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Keeps navbar background color black in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }
        
        tableView.separatorStyle = .none
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        if type == .campus {
            searchController.searchBar.placeholder = "Search campus..."
            API42Manager.shared.getAllCampus { (campus) in
                self.campus = campus
                self.isLoading = false
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
            }
        } else if type == .cursus {
            searchController.searchBar.placeholder = "Search cursus..."
            API42Manager.shared.getAllCursus { (cursus) in
                self.cursus = cursus
                self.isLoading = false
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
            }
        } else if type == .project, let id = delegate?.selectedCursus.id {
            searchController.searchBar.placeholder = "Search project..."
            API42Manager.shared.getAllProjects(forCursus: id) { (projects) in
                self.projects = projects
                self.isLoading = false
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
            }
        } else {
            tableView.separatorStyle = .singleLine
            isLoading = false
        }
    }
    
    @objc func refreshTable(_ sender: Any) {
        if type == .campus {
            API42Manager.shared.getAllCursus(refresh: true) { (campus) in
                self.campus = campus
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        } else if type == .cursus {
            API42Manager.shared.getAllCursus(refresh: true) { (cursus) in
                self.cursus = cursus
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        } else if type == .project, let id = delegate?.selectedCursus.id {
            API42Manager.shared.getAllProjects(forCursus: id, refresh: true) { (projects) in
                self.projects = projects
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 1 }
        
        switch type {
        case .campus:
            return isFiltering() ? filteredCampus.count : campus.count
        case .cursus:
            return isFiltering() ? filteredCursus.count : cursus.count
        case .project:
            return isFiltering() ? filteredProjects.count : projects.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        switch type {
        case .campus:
            delegate.selectedCampus = isFiltering() ? filteredCampus[indexPath.row] : campus[indexPath.row]
            self.navigationController?.popViewController(animated: true)
        case .cursus:
            delegate.selectedCursus = isFiltering() ? filteredCursus[indexPath.row] : cursus[indexPath.row]
            self.navigationController?.popViewController(animated: true)
        case .project:
            delegate.selectedProject = isFiltering() ? filteredProjects[indexPath.row] : projects[indexPath.row]
            delegate.searchButtonEnabled = true
            self.navigationController?.popViewController(animated: true)
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        switch type {
        case .campus:
            let name = isFiltering() ? filteredCampus[indexPath.row].name : campus[indexPath.row].name
            cell.textLabel?.text = name
            cell.accessoryType = name == delegate?.selectedCampus.name ? .checkmark : .none
        case .cursus:
            let name = isFiltering() ? filteredCursus[indexPath.row].name : cursus[indexPath.row].name
            cell.textLabel?.text = name
            cell.accessoryType = name == delegate?.selectedCursus.name ? .checkmark : .none
        case .project:
            let project = isFiltering() ? filteredProjects[indexPath.row] : projects[indexPath.row]
            cell.textLabel?.text = project.name
            cell.detailTextLabel?.text = project.slug
            cell.accessoryType = project.name == delegate?.selectedProject.name ? .checkmark : .none
        }
        return cell
    }
}

// MARK: - Search Results Updating
extension PeerListController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let searchText = searchBar.text {
            filterTable(forSearch: searchText)
        }
    }
    
    func filterTable(forSearch search: String) {
        switch type {
        case .campus:
            filteredCampus = campus.filter({ (item) -> Bool in
                return item.name.lowercased().contains(search.lowercased())
            })
        case .cursus:
            filteredCursus = cursus.filter({ (item) -> Bool in
                return item.name.lowercased().contains(search.lowercased())
            })
        case .project:
            filteredProjects = projects.filter({ (item) -> Bool in
                return item.name.lowercased().contains(search.lowercased())
            })
        }
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}
