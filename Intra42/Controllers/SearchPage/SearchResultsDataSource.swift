//
//  SearchResultsDataSource.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-22.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

protocol SearchResultsDataSource {
    
    var searchBar: UISearchBar { get set }

    func setupSearchBar()
    func showSearchResultsController(atDestination destination: SearchResultsController)
}

extension SearchResultsDataSource {
    
    func showSearchResultsController(atDestination destination: SearchResultsController) {
        guard let text = searchBar.text else { return }
        destination.searchBar.text = text
        destination.isLoadingSearchData = true
        API42Manager.shared.searchUsers(withString: text, completionHander: destination.populateSearchTable)
        searchBar.text = ""
    }
    
    func setupSearchBar() {
        searchBar.sizeToFit()
        searchBar.placeholder = "Search students..."
        searchBar.autocapitalizationType = .none
    }
}
