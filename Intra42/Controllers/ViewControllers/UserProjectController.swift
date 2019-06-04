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
        tableView.estimatedRowHeight = 400
        tableView.estimatedSectionHeaderHeight = 60
    }
}

// MARK: - Table view data source

extension UserProjectController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamHeaderCell") as! ProjectTeamHeaderCell
        cell.setupView("femaury's team", "123%", "6 months ago", "6 months ago")
        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamGitCell") as! ProjectTeamGitCell
            cell.repoLinkLabel.text = "vogsphere@vogsphere.42.fr:intra/2018/activities/camagru/femaury"
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamUsersCell") as! ProjectTeamUsersCell
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamEvaluationHeaderCell") as! ProjectTeamEvaluationHeaderCell
            cell.evaluationCountLabel.text = "(2/5)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTeamEvaluationCell") as! ProjectTeamEvaluationCell
            // swiftlint:disable line_length
            cell.setupView(with: Evaluation(correctorName: "femaury",
                                            timeAgo: "6 months ago",
                                            grade: "120%",
                                            isValid: true,
                                            comment: "Good shit ma boi Good shit ma boi Good shit ma boi Good shit ma boi Good shit ma boi Good shit ma boi v Good shit ma boi Good shit ma boi v Good shit ma boi Good shit ma boi Good shit ma boi toto",
                                            feedback: "Thanks homie"))
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
