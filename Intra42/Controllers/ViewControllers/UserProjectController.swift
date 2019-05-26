//
//  UserProjectController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class UserProjectController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.estimatedSectionHeaderHeight = 60
    }
}

// MARK: - Table view data source

extension UserProjectController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamHeaderCell") as! ProjectTeamHeaderCell
        
        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamGitCell") as! ProjectTeamGitCell
            cell.repoLinkLabel.text = "Whoop whoop git master race"
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamUsersCell") as! ProjectTeamUsersCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamEvaluationsCell") as! ProjectTeamEvaluationsCell
            cell.setupEvaluations(evaluations: [])
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
