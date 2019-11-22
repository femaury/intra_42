//
//  UserProjectController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class UserProjectController: UITableViewController {
    
    var projectTeams: [ProjectTeam]?
    var correctorId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fixes navbar background color bug in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }

        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.estimatedSectionHeaderHeight = 60
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserProfileSegue" {
            if let id = correctorId, let destination = segue.destination as? UserProfileController {
                let url = API42Manager.shared.baseURL + "users/\(id)"
                API42Manager.shared.request(url: url) { (data) in
                    guard let data = data else { return }
                    destination.userProfile = UserProfile(data: data)
                    if let userId = destination.userProfile?.userId {
                        API42Manager.shared.getCoalitionInfo(forUserId: userId, completionHandler: { (name, color, logo) in
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
    
    func showCorrectorProfile(withId id: Int) {
        correctorId = id
        performSegue(withIdentifier: "UserProfileSegue", sender: self)
    }
}

// MARK: - Table view data source

extension UserProjectController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let count = projectTeams?.count else {
            return 1
        }
        return count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let teams = projectTeams else {
            return 1
        }
        let team = teams[section]
        if team.evaluations.count == 0 {
            return 4
        }
        return 3 + team.evaluations.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let teams = projectTeams else {
            return nil
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamHeaderCell") as! ProjectTeamHeaderCell
        let team = teams[section]
        cell.setupView(team.name, "\(team.finalGrade)%", team.isValidated, team.closedAt ?? "Not closed yet", team.lockedAt ?? "Not locked yet")
        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let teams = projectTeams else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingIndicatorCell")!
            return cell
        }
        let team = teams[indexPath.section]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamGitCell") as! ProjectTeamGitCell
            cell.repoLinkLabel.text = team.repoURL
            cell.delegate = self
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamUsersCell") as! ProjectTeamUsersCell
            cell.setupView(with: team.users)
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamEvaluationHeaderCell") as! ProjectTeamEvaluationHeaderCell
            cell.evaluationCountLabel.text = ""
            return cell
        } else {
            if team.evaluations.count == 0 {
                var cell: UITableViewCell!
                cell = tableView.dequeueReusableCell(withIdentifier: "NoEvaluationsCell")
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "NoEvaluationsCell")
                }
                cell.textLabel?.text = "None"
                cell.textLabel?.textColor = .gray
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamEvaluationCell") as! ProjectTeamEvaluationCell
            let evaluation = team.evaluations[indexPath.row - 3]
            cell.setupView(with: evaluation)
            cell.delegate = self
            return cell
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
