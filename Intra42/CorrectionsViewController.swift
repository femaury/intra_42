//
//  CorrectionsViewController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-28.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class CorrectionsViewController: UIViewController {

    lazy var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
//        API42Manager.shared.request(url: "https://api.intra.42.fr/v2/achievements?page[size]=100") { (data) in
//            print(data ?? "No data")
//            print(data?.arrayValue.count ?? "nil")
//            API42Manager.shared.request(url: "https://api.intra.42.fr/v2/achievements?page[number]=2&page[size]=100", completionHandler: { (data) in
//                print(data ?? "No data")
//                print(data?.arrayValue.count ?? "nil")
//            })
//        }
        API42Manager.shared.request(url: "https://api.intra.42.fr/v2/coalitions?page[size]=100") { (data) in
            print(data ?? "No data")
            print(data?.arrayValue.count ?? "nil")
        }
    }

    @objc func tapHandler(gesture: UIGestureRecognizer) {
        self.searchBar.resignFirstResponder()
    }
}

// MARK: - Prepare for segue

extension CorrectionsViewController: SearchResultsDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegue" {
            if let destination = segue.destination as? SearchResultsController {
                showSearchResultsController(atDestination: destination)
            }
        }
    }
}

// MARK: - Search Bar Delegate

extension CorrectionsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            performSegue(withIdentifier: "SearchResultsSegue", sender: self)
        }
        searchBar.resignFirstResponder()
    }
}
