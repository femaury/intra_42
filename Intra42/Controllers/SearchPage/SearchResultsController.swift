//
//  SearchResultsController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-04.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

enum SearchSection {
    case username
    case firstName
    case lastName
}

class SearchResultsController: UITableViewController, SearchResultsDataSource {

    lazy var searchBar = UISearchBar()
    
    var loginSearchResults: [(id: Int, Login: String)] = []
    var firstNameSearchResults: [(id: Int, Login: String)] = []
    var lastNameSearchResults: [(id: Int, Login: String)] = []
    
    var selectedCell: UserProfileCell?
    
    var userProfilePictures: [Int : UIImage] = [:]
    
    var isLoadingSearchData = true {
        didSet {
            if oldValue != isLoadingSearchData {
                self.tableView.reloadData()
                tableView.scrollToNearestSelectedRow(at: .bottom, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 50
        tableView.keyboardDismissMode = .onDrag
        
        setupSearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func populateSearchTable(data: JSON?, section: SearchSection) {
        guard let data = data else { return }
        
        for user in data.arrayValue {
            guard
                let id = user["id"].int,
                let login = user["login"].string
            else { continue }
            
            switch section {
            case .username:
                self.loginSearchResults.append((id, login))
            case .firstName:
                self.firstNameSearchResults.append((id, login))
            case .lastName:
                self.lastNameSearchResults.append((id, login))
            }
            
            if self.userProfilePictures.keys.contains(id) { continue }
            self.getProfilePictureOfUser(withId: id, login: login)
        }
        if section == .firstName {
            self.isLoadingSearchData = false
            self.tableView.reloadData()
        }
    }
    
    func getProfilePictureOfUser(withId id: Int, login: String) {
        API42Manager.shared.getProfilePicture(withLogin: login) { (image) in
            self.userProfilePictures[id] = image
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func addUser(friend: Friend) {
        FriendDataManager.shared.saveNewFriend(friend)
    }
}

// MARK: - Prepare for segue

extension SearchResultsController: UserProfileDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserProfileSegue" {
            if let destination = segue.destination as? UserProfileController {
                showUserProfileController(atDestination: destination)
            }
        }
    }
}


// MARK: - Search Bar Delegate

extension SearchResultsController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text {
            self.isLoadingSearchData = true
            self.loginSearchResults = []
            self.firstNameSearchResults = []
            self.lastNameSearchResults = []
            API42Manager.shared.searchUsers(withString: text, completionHander: populateSearchTable)
        }
    }
}

// MARK: - Table view data source

extension SearchResultsController {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        searchBar.resignFirstResponder()
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserResultCell else { return }
        selectedCell = cell
        performSegue(withIdentifier: "UserProfileSegue", sender: self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isLoadingSearchData == false {
            if loginSearchResults.count > 0 || firstNameSearchResults.count > 0 || lastNameSearchResults.count > 0 {
                return 3
            }
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isLoadingSearchData == false {
            if loginSearchResults.count > 0 || firstNameSearchResults.count > 0 || lastNameSearchResults.count > 0 {
                switch section {
                case 0:
                    return "Usernames"
                case 1:
                    return "First Names"
                default:
                    return "Last Names"
                }
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoadingSearchData == false {
            if loginSearchResults.count > 0 || firstNameSearchResults.count > 0 || lastNameSearchResults.count > 0 {
                switch section {
                case 0:
                    return loginSearchResults.count
                case 1:
                    return firstNameSearchResults.count
                default:
                    return lastNameSearchResults.count
                }
            }
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoadingSearchData == false && (loginSearchResults.count > 0 || firstNameSearchResults.count > 0 || lastNameSearchResults.count > 0) {
            return 75
        } else {
            return tableView.frame.height
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingSearchData == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingIndicatorCell")!
            return cell
        } else if loginSearchResults.count > 0 || firstNameSearchResults.count > 0 || lastNameSearchResults.count > 0 {
            
            var userInfo = loginSearchResults
            
            if indexPath.section == 1 {
                userInfo = firstNameSearchResults
            } else if indexPath.section == 2 {
                userInfo = lastNameSearchResults
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserResultCell") as! UserResultCell
            let id = userInfo[indexPath.row].id
            cell.usernameLabel.text = userInfo[indexPath.row].Login
            cell.userPicture.image = nil
            if let picture = userProfilePictures[id] {
                cell.loadingIndicator.stopAnimating()
                cell.userPicture.image = picture
            }
            cell.setupAddUserButton(isFriend: FriendDataManager.shared.hasFriend(withId: id))
            cell.delegate = self
            cell.userId = id
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoResultsCell")!
            return cell
        }
    }
}
