//
//  ProfileTableCells.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-22.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

extension UITableViewDataSource {
    func setupProfileCells(_ tableView: UITableView, _ indexPath: IndexPath, _ section: ProfileSection, _ userProfile: UserProfile) -> UITableViewCell {
        switch section {
        case .cursus:
            let cursus = userProfile.cursusList[indexPath.row]
            var cell: UITableViewCell!
            cell = tableView.dequeueReusableCell(withIdentifier: "CursusCell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "CursusCell")
            }
            cell.textLabel?.text = cursus.name
            let borderBottom = UIView(frame: CGRect(x: 0, y: 39, width: tableView.frame.width, height: 1))
            borderBottom.backgroundColor = UIColor(hexRGB: "#E5E5E5")
            cell.addSubview(borderBottom)
            return cell
        case .projects:
            let project = userProfile.projects.reversed()[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") as! ProjectCell
            cell.projectNameBtn.setTitle(project.name, for: .normal)
            cell.gradeLabel.text = String(project.grade)
            if project.validated == false {
                cell.gradeLabel.textColor = UIColor.red
            } else {
                cell.gradeLabel.textColor = Colors.Grades.valid
            }
            cell.timeAgoLabel.text = project.finished?.getElapsedInterval()
            return cell
        case .logs:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogsTableCell") as! LogsTableCell
            cell.locationLogs = userProfile.locationLogs
            return cell
        case .achievements:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementCell") as! AchievementCell
            let index = userProfile.achievementsIndices[indexPath.row]
            cell.isOwned = true
            cell.achievement = userProfile.achievements[index]
            return cell
        }
    }
}
