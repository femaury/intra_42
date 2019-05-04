//
//  UserProfileController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-04.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class UserProfileController: UITableViewController {

    var userProfile: UserProfile?
    var userActions: UserActions?
    var coalitionColor: UIColor?
    var coalitionLogo: String?
    var coalitionName: String?
    var isLoadingData = true
    var sectionToDisplay: ProfileSection = .projects {
        didSet {
            guard isLoadingData == false else { return }
            tableView.scrollToNearestSelectedRow(at: .top, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.register(LogsTableCell.self, forCellReuseIdentifier: "LogsTableCell")
        
        let removeClosure: (UIAlertAction) -> Void = { [weak self] (action) in
            guard let self = self, let id = self.userProfile?.userId else { return }
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "add_user_male")
            FriendDataManager.shared.deleteFriend(withId: id)
            self.navigationController?.popViewController(animated: true)
        }
        userActions = UserActions(removeFriendClosure: removeClosure, cancelClosure: nil)
    }
    
    @IBAction func changeFriendStatus(_ sender: UIBarButtonItem) {
        guard let userProfile = self.userProfile, let removeAction = userActions?.removeFriend else { return }
        let id = userProfile.userId
        if FriendDataManager.shared.hasFriend(withId: id) {
            present(removeAction, animated: true, completion: nil)
        } else {
            let username = userProfile.username
            let phone = userProfile.phoneNumber
            let email = userProfile.email
            let friend = Friend(id: id, username: username, phone: phone, email: email)
            
            FriendDataManager.shared.saveNewFriend(friend)
            navigationItem.rightBarButtonItem?.image = UIImage(named: "delete_user_male")
        }
    }
    
    @IBAction func showHolyGraph(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "HolyGraphSegue", sender: self)
    }
    
    @objc func refreshTable(_ sender: Any) {
        guard let id = userProfile?.userId else {
            tableView.refreshControl?.endRefreshing()
            return
        }
        API42Manager.shared.request(url: "https://api.intra.42.fr/v2/users/\(id)") { [weak self] (data) in
            guard let self = self, let data = data else { return }
            self.userProfile = UserProfile(data: data)
            if let userId = self.userProfile?.userId {
                API42Manager.shared.getCoalitionInfo(withUserId: userId) { [weak self] (name, color, logo) in
                    guard let self = self else { return }
                    self.coalitionName = name
                    self.coalitionColor = color
                    self.coalitionLogo = logo
                    self.isLoadingData = false
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Friend Action Delegate: Action Sheets

extension UserProfileController {
    
    func callUser() {
        if let callAction = userActions?.call {
            callAction.title = userProfile?.phoneNumber
            present(callAction, animated: true, completion: nil)
        }
    }
    
    func emailUser() {
        if let emailAction = userActions?.email {
            emailAction.title = userProfile?.email
            present(emailAction, animated: true, completion: nil)
        }
    }
}

// MARK: - Table view data source

extension UserProfileController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userProfile = self.userProfile, isLoadingData == false else { return }
        if indexPath.section == 1 {
            switch sectionToDisplay {
            case .cursus:
                guard
                    let cell = tableView.cellForRow(at: indexPath),
                    let name = cell.textLabel?.text
                    else { return }
                for cursus in userProfile.cursusList {
                    if cursus.name == name {
                        userProfile.getLevelAndSkills(cursusId: cursus.id)
                        userProfile.getProjects(cursusId: cursus.id)
                        tableView.reloadData()
                        break
                    }
                }
            case .projects:
                return
            case .logs:
                return
            case .achievements:
                return
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isLoadingData ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLoadingData {
            return 0
        }
        if section == 0 {
            return 400
        } else {
            return 35
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let userProfile = self.userProfile else { return nil }
        
        if FriendDataManager.shared.hasFriend(withId: userProfile.userId) {
            navigationItem.rightBarButtonItem?.image = UIImage(named: "delete_user_male")
        }
        
        if section == 0 {
            let view = tableView.dequeueReusableCell(withIdentifier: "UserHeaderCell") as! UserHeaderCell
            view.coalitionLogo = coalitionLogo
            view.coalitionColor = coalitionColor
            view.coalitionName = coalitionName
            view.userProfile = userProfile
            view.delegate = self
            return view
        } else {
            let view = tableView.dequeueReusableCell(withIdentifier: "SegmentHeaderCell") as! SegmentHeaderCell
            view.segmentControl.selectedSegmentIndex = sectionToDisplay.rawValue
            view.segmentCallback = { [weak self] (section) in
                guard let self = self, let section = ProfileSection(rawValue: section) else { return }
                self.sectionToDisplay = section
                self.tableView.reloadData()
            }
            return view
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoadingData {
            return tableView.frame.height
        }
        if sectionToDisplay == .achievements {
            return 100
        } else if sectionToDisplay == .logs {
            return tableView.frame.height
        }
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userProfile = self.userProfile else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingIndicatorCell")!
            return cell
        }
        if indexPath.section == 1 {
            return setupProfileCells(tableView, indexPath, sectionToDisplay, userProfile)
        } else {
            return UITableViewCell()
        }
    }

}
