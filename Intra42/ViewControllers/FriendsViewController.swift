//
//  FriendsViewController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-28.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SwiftyJSON

class FriendsViewController: UIViewController {

    lazy var searchBar = UISearchBar()
    var userActions: UserActions?
    
    var cellToDelete: FriendCell?
    var selectedCell: UserProfileCell?
    var friends: [Friend] = []
    var friendLocations: [Int: String] = [:] {
        didSet { tableView.reloadData() }
    }
    var friendPictures: [Int: UIImage] = [:]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar

        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.keyboardDismissMode = .onDrag
        
        // Friend Cell Action Sheets
        let cancelClosure: (UIAlertAction) -> Void = { [weak self] action in
            self?.cellToDelete = nil
        }
        userActions = UserActions(removeFriendClosure: nil, cancelClosure: cancelClosure)
        
        // Populate Table
        friends = FriendDataManager.shared.friends
        getFriendPictures()
        getFriendLocations()
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
    
    @objc func refreshTable(_ sender: Any) {
        let newFriends = FriendDataManager.shared.friends
        if newFriends.count != self.friends.count {
            friends = newFriends
        }
        getFriendPictures()
        getFriendLocations()
        tableView.reloadData()
    }
    
    func getFriendLocations() {
        guard friends.count > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.tableView.refreshControl?.endRefreshing()
            }
            return
        }
        var friendIds: [String] = []
        for friend in friends {
            friendIds.append(String(friend.id))
        }
        let idString = friendIds.joined(separator: ",")
        API42Manager.shared.request(url: "https://api.intra.42.fr/v2/locations?filter[user_id]=\(idString)&filter[active]=true") { (data) in
            guard let data = data else { return }
            print(data)
            for connection in data.arrayValue {
                let id = connection["user"]["id"].intValue
                let location = connection["host"].stringValue
//                let campus = connection["campus_id"].intValue // TODO
                self.friendLocations.updateValue(location, forKey: id)
            }
            self.orderFriendsByLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    func orderFriendsByLocation() {
        var newFriendList: [Friend] = []

        for friend in friends {
            if let location = friendLocations[friend.id] {
                if location.isEmpty == false {
                    newFriendList.append(friend)
                    friends.remove(at: friends.firstIndex(where: {$0 == friend})!)
                }
            }
        }
        newFriendList += friends
        friends = newFriendList
    }
    
    func getFriendPictures() {
        for friend in friends {
            let id = friend.id
            let login = friend.username
            
            if friendPictures[id] != nil { continue }
            API42Manager.shared.getProfilePicture(withLogin: login) { (image) in
                guard let image = image else { return }
                self.friendPictures.updateValue(image, forKey: id)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Prepare for segue

extension FriendsViewController: UserProfileDataSource, SearchResultsDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegue" {
            if let destination = segue.destination as? SearchResultsController {
                showSearchResultsController(atDestination: destination)
            }
        } else if segue.identifier == "UserProfileSegue" {
            if let destination = segue.destination as? UserProfileController {
                showUserProfileController(atDestination: destination)
            }
        }
    }
}

// MARK: - Action Sheet Functions

extension FriendsViewController {
    
    func callFriend(withId id: Int, phone: String) {
        if let callAction = userActions?.call {
            callAction.title = phone
            present(callAction, animated: true, completion: nil)
        }
    }
    
    func emailFriend(withId id: Int, email: String) {
        if let emailAction = userActions?.email {
            emailAction.title = email
            present(emailAction, animated: true, completion: nil)
        }
    }
}

// MARK: - Search Bar Delegate

extension FriendsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            performSegue(withIdentifier: "SearchResultsSegue", sender: self)
        }
        searchBar.resignFirstResponder()
    }
}

// MARK: - Table View Delegate

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let delete = UIContextualAction(style: .destructive, title: "Remove") { (action, sourceView, completionHandler) in
//            completionHandler(true)
//        }
//        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
//        swipeAction.performsFirstActionWithFullSwipe = false
//        return swipeAction
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Remove") { (_, indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as! FriendCell
            let id = cell.userId
            self.friends.remove(at: self.friends.firstIndex(where: {$0.id == id})!)
            self.tableView.deleteRows(at: [cell.indexPath], with: .left)
            FriendDataManager.shared.deleteFriend(withId: id)
        }
        
        return [delete]
    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .delete) {
//            let cell = tableView.cellForRow(at: indexPath) as! FriendCell
//            let id = cell.userId
//            print(id)
//            self.friends.remove(at: self.friends.firstIndex(where: {$0.id == id})!)
//            self.tableView.deleteRows(at: [cell.indexPath], with: .left)
//            FriendDataManager.shared.deleteFriend(withId: id)
//        }
//    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FriendCell else { return }
        selectedCell = cell
        performSegue(withIdentifier: "UserProfileSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return friends.count > 0 ? 75 : tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count > 0 ? friends.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if friends.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoFriendCell")!
            return cell
        } else {
            let friend = friends[indexPath.row]
            let id = friend.id
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
            cell.friend = friend
            cell.picture = friendPictures[id]
            cell.indexPath = indexPath
            cell.delegate = self
            if let location = friendLocations[id], !location.isEmpty {
                cell.location = location
            } else {
                cell.locationLabel.text = "Unavailable"
                cell.isOnline.isHidden = true
            }
            return cell
        }
    }
}
