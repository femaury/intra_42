//
//  HomeViewController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-27.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

enum ProfileSection: Int {
    case cursus = 0
    case projects = 1
    case logs = 2
    case achievements = 3
}

class HomeViewController: UIViewController {
    
    lazy var searchBar = UISearchBar()
    @IBOutlet var tableView: UITableView!
    
    var sectionToDisplay: ProfileSection = .projects {
        didSet {
            guard isLoadingData == false else { return }
            tableView.scrollToNearestSelectedRow(at: .top, animated: true)
        }
    }
    var isLoadingData = true
    var userProfile: UserProfile?
    var selectedProjectTeams: [ProjectTeam]?
    var selectedProjectName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        API42Manager.shared.userProfileCompletionHandler = { userProfile in
            if userProfile == nil { return }
            self.isLoadingData = false
            self.userProfile = userProfile
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        API42Manager.shared.coalitionColorCompletionHandler = { color in
//            self.tabBarController?.tabBar.barTintColor = color
            
            self.tabBarController?.tabBar.tintColor = color

            if let children = self.tabBarController?.children {
                for child in children {
                    guard let navController = child as? UINavigationController else { continue }
//                    navController.navigationBar.barTintColor = color
//                    navController.navigationBar.tintColor = UIColor.black
                    
                    navController.navigationBar.tintColor = color
                }
            }
        }
        
        setupSearchBar()
        searchBar.delegate = self
        searchBar.barTintColor = .lightGray
        navigationItem.titleView = searchBar
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.keyboardDismissMode = .onDrag
        tableView.register(LogsTableCell.self, forCellReuseIdentifier: "LogsTableCell")
        
//        tabBarController?.tabBar.barTintColor = Colors.intraTeal
//        tabBarController?.tabBar.tintColor = UIColor.black
//        tabBarController?.tabBar.unselectedItemTintColor = UIColor.white

        tabBarController?.tabBar.tintColor = Colors.intraTeal

//        navigationController?.navigationBar.barTintColor = Colors.intraTeal
//        navigationController?.navigationBar.tintColor = UIColor.black

        navigationController?.navigationBar.tintColor = Colors.intraTeal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    @objc func tapHandler(gesture: UIGestureRecognizer) {
        self.searchBar.resignFirstResponder()
    }
    
    @objc func refreshTable(_ sender: Any) {
        API42Manager.shared.setupAPIData()
    }
}

// MARK: - Prepare for segue

extension HomeViewController: SearchResultsDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegue" {
            if let destination = segue.destination as? SearchResultsController {
                showSearchResultsController(atDestination: destination)
            }
        } else if segue.identifier == "UserProjectSegue" {
            if let destination = segue.destination as? UserProjectController {
                destination.projectTeams = selectedProjectTeams
                var title = ""
                if let projectName = selectedProjectName {
                    if projectName.count > 20 {
                        title = String(projectName.prefix(20)) + "..."
                    } else {
                        title = projectName
                    }
                }
                destination.title = title
            }
        }
    }
}

// MARK: - Search Bar Extension

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            performSegue(withIdentifier: "SearchResultsSegue", sender: self)
        }
        searchBar.resignFirstResponder()
    }
}

// MARK: - Table View Extension

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userProfile = self.userProfile, isLoadingData == false else { return }
        if indexPath.section == 1 {
            switch sectionToDisplay {
            case .cursus:
                guard
                    let cell = tableView.cellForRow(at: indexPath),
                    let name = cell.textLabel?.text
                else { return }
                for cursus in userProfile.cursusList where cursus.name == name {
                    userProfile.getLevelAndSkills(cursusId: cursus.id)
                    userProfile.getProjects(cursusId: cursus.id)
                    tableView.reloadData()
                    break
                }
            case .projects:
                let project = userProfile.projects.reversed()[indexPath.row]
                let projectId = project.id
                let id = userProfile.userId
                selectedProjectName = project.name
                API42Manager.shared.getTeam(forUserId: id, projectId: projectId) { [weak self] (projectTeams) in
                    print("PROJECT \(id): \(projectTeams)")
                    self?.selectedProjectTeams = projectTeams
                    self?.performSegue(withIdentifier: "UserProjectSegue", sender: self)
                }
                return
            case .logs:
                return
            case .achievements:
                return
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isLoadingData ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLoadingData {
            return 0
        }
        if section == 0 {
            return 350
        } else {
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let userProfile = self.userProfile else { return nil }
        
        if section == 0 {
            let view = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell") as! ProfileHeaderCell
            view.userProfile = userProfile
            return view
        } else {
            let view = tableView.dequeueReusableCell(withIdentifier: "SegmentHeaderCell") as! SegmentHeaderCell
            view.segmentControl.selectedSegmentIndex = sectionToDisplay.rawValue
            view.segmentControl.tintColor = API42Manager.shared.coalitionColor
            view.topLine.backgroundColor = API42Manager.shared.coalitionColor
            view.bottomLine.backgroundColor = API42Manager.shared.coalitionColor
            view.segmentCallback = { section in
                guard let section = ProfileSection(rawValue: section) else { return }
                self.sectionToDisplay = section
                self.tableView.reloadData()
            }
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let userProfile = self.userProfile else { return 1 }
        if section == 1 {
            switch sectionToDisplay {
            case .cursus:
                return userProfile.cursusList.count
            case .projects:
                return userProfile.projects.count
            case .logs:
                return 1
            case .achievements:
                return userProfile.achievements.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoadingData {
            return tableView.frame.height
        }
        if sectionToDisplay == .achievements {
            return 75
        } else if sectionToDisplay == .logs {
            return tableView.frame.height
        }
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userProfile = self.userProfile else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingIndicatorCell")!
            return cell
        }
        if indexPath.section == 1 {
            return setupProfileCells(tableView, indexPath, sectionToDisplay, userProfile)
        }
        return UITableViewCell()
    }
}