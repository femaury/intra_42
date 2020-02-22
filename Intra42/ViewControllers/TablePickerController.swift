//
//  TablePickerController.swift
//  Intra42
//
//  Created by Felix Maury on 13/02/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

typealias TablePickerItem = (id: Int, name: String)
typealias TablePickerDataSource = (Bool, @escaping ([TablePickerItem]) -> Void) -> Void

protocol TablePickerDelegate: class {
    func selectItem(_ item: TablePickerItem) -> Void
}

class TablePickerController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    weak var delegate: TablePickerDelegate?
    var dataSource: TablePickerDataSource?
    var isLoading = true
    
    var items: [TablePickerItem] = []
    var filteredItems: [TablePickerItem] = []
    var selectedItem: TablePickerItem?

    override func viewDidLoad() {
        super.viewDidLoad()

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

        loadTablePickerItems()
    }
    
    func loadTablePickerItems(refresh: Bool = false) {
        guard let dataSource = dataSource else { return }
        dataSource(refresh) { [weak self] items in
            self?.items = items
            self?.isLoading = false
            self?.tableView.separatorStyle = .singleLine
            self?.tableView.reloadData()
        }
    }
    
    @objc func refreshTable(_ sender: Any) {
        loadTablePickerItems(refresh: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 1 }
        return isFiltering() ? filteredItems.count : items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let item = isFiltering() ? filteredItems[indexPath.row] : items[indexPath.row]
        delegate.selectItem(item)
        self.navigationController?.popViewController(animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")

        let name = isFiltering() ? filteredItems[indexPath.row].name : items[indexPath.row].name
        cell.textLabel?.text = name
        cell.accessoryType = name == selectedItem?.name ? .checkmark : .none
        return cell
    }
}

// MARK: - Search Results Updating
extension TablePickerController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let searchText = searchBar.text {
            filterTable(forSearch: searchText)
        }
    }
    
    func filterTable(forSearch search: String) {
        filteredItems = items.filter({ (item) -> Bool in
            return item.name.lowercased().contains(search.lowercased())
        })
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
