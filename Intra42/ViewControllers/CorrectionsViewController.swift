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
    
    var selectedTeamUserId: Int = Int()
    var selectedTeamProjectId: Int = Int()
    var selectedTeamProjectName: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fixes navbar background color bug in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func getCorrections() {
        API42Manager.shared.getScales { (scales) in
            self.corrections = scales
            self.isLoadingCorrections = false
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
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

    func showCorecteeTeamPage(projectId: Int, userId: Int, projectName: String) {
        selectedTeamUserId = userId
        selectedTeamProjectId = projectId
        selectedTeamProjectName = projectName
        performSegue(withIdentifier: "UserProjectSegue", sender: self)
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
                let url = API42Manager.shared.baseURL + "users/\(id)"
                API42Manager.shared.request(url: url) { (data) in
                    guard let data = data else { return }
                    destination.userProfile = UserProfile(data: data)
                    if let userId = destination.userProfile?.userId {
                        API42Manager.shared.getCoalitionInfo(forUserId: userId, completionHandler: { (name, color, bgURL) in
                            destination.coalitionName = name
                            destination.coalitionColor = color
                            destination.coalitionBgURL = bgURL
                            destination.isLoadingData = false
                            destination.tableView.reloadData()
                        })
                    }
                }
            }
        } else if segue.identifier == "UserProjectSegue" {
            if let destination = segue.destination as? UserProjectController {
                let projectId = selectedTeamProjectId
                let id = selectedTeamUserId
                let name = selectedTeamProjectName
                
                API42Manager.shared.getTeam(forUserId: id, projectId: projectId) { projectTeams in
                    if name.count > 20 {
                        destination.title = String(name.prefix(20)) + "..."
                    } else {
                        destination.title = name
                    }
                    destination.projectTeams = projectTeams
                    destination.tableView.reloadData()
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
        if isLoadingCorrections || corrections.count == 0 {
            return tableView.frame.height
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoadingCorrections || corrections.count == 0 {
            return 1
        }
        return corrections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingCorrections, let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingIndicatorCell") {
            return cell
        }
        if corrections.count == 0 {
            var cell: UITableViewCell!
            cell = tableView.dequeueReusableCell(withIdentifier: "NoCorrectionsCell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "NoCorrectionsCell")
            }
            cell.textLabel?.text = "You do not have any upcoming corrections..."
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            return cell
        }
        
        let correction = corrections[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScalesCell") as! ScalesCell
        cell.setupCell(correction: correction, delegate: self)
        return cell
    }
}
