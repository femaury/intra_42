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
    @IBOutlet weak var tableView: UITableView!
    
    var isLoadingCorrections = true
    var corrections: [Correction] = []
    var correctorId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        getCorrections()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    // TODO: Fix infinite loading when no corrections?
    func getCorrections() {
        API42Manager.shared.getScales { (scales) in
            self.corrections = scales
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            self.isLoadingCorrections = false
        }
    }
    
    func showCorrectorProfile(withId id: Int) {
        if id == API42Manager.shared.userProfile?.userId, let tbc = tabBarController {
            tbc.selectedIndex = 0
        } else {
            correctorId = id
            performSegue(withIdentifier: "UserProfileSegue", sender: self)
        }
    }

    @objc func tapHandler(gesture: UIGestureRecognizer) {
        self.searchBar.resignFirstResponder()
    }
    
    @objc func refreshTable(_ sender: Any) {
        getCorrections()
    }
}

// MARK: - Prepare for segue

extension CorrectionsViewController: SearchResultsDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegue" {
            if let destination = segue.destination as? SearchResultsController {
                showSearchResultsController(atDestination: destination)
            }
        } else if segue.identifier == "UserProfileSegue" {
            if let id = correctorId, let destination = segue.destination as? UserProfileController {
                API42Manager.shared.request(url: "https://api.intra.42.fr/v2/users/\(id)") { (data) in
                    guard let data = data else { return }
                    destination.userProfile = UserProfile(data: data)
                    if let userId = destination.userProfile?.userId {
                        API42Manager.shared.getCoalitionInfo(withUserId: userId, completionHandler: { (name, color, logo) in
                            destination.coalitionName = name
                            destination.coalitionColor = color
                            destination.coalitionLogo = logo
                            destination.isLoadingData = false
                            destination.tableView.reloadData()
                        })
                    }
                }
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

// MARK: - Table View Delegate / Data Source

extension CorrectionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoadingCorrections {
            return tableView.frame.height
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoadingCorrections {
            return 1
        }
        return corrections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingCorrections, let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingIndicatorCell") {
            return cell
        }
        let correction = corrections[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScalesCell") as! ScalesCell
        cell.setupCell(correction: correction, delegate: self)
        return cell
    }
}
