//
//  PeerFinderViewController.swift
//  Intra42
//
//  Created by Felix Maury on 07/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class PeerFinderViewController: UITableViewController {

    enum Filter {
        case validated
        case inProgress
        case all
    }
    var selectedCampus: (id: Int, name: String) = (0, "None")
    var selectedCursus: (id: Int, name: String) = (0, "None")
    var selectedProject: ProjectItem = ProjectItem(name: "None", slug: "", id: 0)
    var selectedFilter: Filter = .validated
    var selectedType: PeerListType?
    var searchButtonEnabled = false { didSet { tableView.reloadData() } }
    var peerResultsController: PeerResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let id = API42Manager.shared.userProfile?.mainCampusId, let name = API42Manager.shared.userProfile?.mainCampusName {
            selectedCampus = (id, name)
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }
        
        title = "Peer Finder"
        tableView.alwaysBounceVertical = false
        tableView.separatorColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PeerListSegue", let type = selectedType {
            if let destination = segue.destination as? PeerListController {
                destination.delegate = self
                destination.type = type
            }
        }
    }
    
    func selectFilter(_ index: Int) {
        switch index {
        case 0:
            selectedFilter = .validated
        case 1:
            selectedFilter = .inProgress
        case 2:
            selectedFilter = .all
        default:
            return
        }
    }
    
    func searchUsers() {
        let projectId = selectedProject.id
        let campusId = selectedCampus.id
        let filter = selectedFilter
        let id = "\(projectId)\(campusId)\(filter)"
        
        if peerResultsController == nil || peerResultsController?.controllerId != id {
            let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
            peerResultsController = storyboard.instantiateViewController(withIdentifier: "PeerResultsController") as? PeerResultsController
            peerResultsController?.modalPresentationStyle = .fullScreen
            _ = peerResultsController?.view
            peerResultsController?.loadProjectUsers(forProjectId: projectId, campusId: campusId, filter: selectedFilter)
        }
        guard let destination = peerResultsController else { return }
        navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "CAMPUS AND CURSUS"
        case 1:
            return "PROJECT"
        case 2:
            return "FILTERS"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "The projects list is based on selected cursus."
        case 1:
            return "Projects are saved locally, swipe down in the list to check if they are up to date."
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && selectedCursus.id == 0 {
            return nil
        }
        if indexPath.section == 2 {
            return nil
        }
        return indexPath.section == 3 ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedType = indexPath.row == 0 ? .campus : .cursus
        case 1:
            selectedType = .project
        default:
            return
        }
        performSegue(withIdentifier: "PeerListSegue", sender: self)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3, let cell = tableView.dequeueReusableCell(withIdentifier: "SearchButtonCell", for: indexPath) as? SearchButtonCell {
            cell.searchButton.isEnabled = searchButtonEnabled
            cell.searchButton.tintColor = API42Manager.shared.preferedPrimaryColor
            cell.delegate = self
            cell.backgroundColor = nil
            return cell
        }

        let borderWidth = 1.0 / UIScreen.main.scale
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "campusCell")
                ?? UITableViewCell(style: .value1, reuseIdentifier: "campusCell")
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Campus"
                cell.detailTextLabel?.text = selectedCampus.name
                
                for sub in cell.subviews where sub.frame.height == borderWidth {
                    sub.removeFromSuperview()
                }
                let borderTop = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: borderWidth))
                borderTop.backgroundColor = UIColor(named: "SelectedCellBackground")
                cell.addSubview(borderTop)
                let posX = tableView.separatorInset.left
                let borderBottom = UIView(frame: CGRect(x: posX, y: cell.frame.height, width: tableView.frame.width - posX, height: borderWidth))
                borderBottom.backgroundColor = UIColor(named: "SelectedCellBackground")
                cell.addSubview(borderBottom)
            } else {
                cell.textLabel?.text = "Cursus"
                cell.detailTextLabel?.text = selectedCursus.name
                
                for sub in cell.subviews where sub.frame.height == borderWidth {
                    sub.removeFromSuperview()
                }
                let borderBottom = UIView(frame: CGRect(x: 0, y: cell.frame.height, width: tableView.frame.width, height: borderWidth))
                borderBottom.backgroundColor = UIColor(named: "SelectedCellBackground")
                cell.addSubview(borderBottom)
            }
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell")
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: "projectCell")
            
            cell.textLabel?.text = selectedProject.name
            cell.detailTextLabel?.text = selectedProject.slug
            cell.accessoryType = .disclosureIndicator
            
            for sub in cell.subviews where sub.frame.height == borderWidth {
                sub.removeFromSuperview()
            }
            cell.updateConstraintsIfNeeded()
            let borderTop = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: borderWidth))
            borderTop.backgroundColor = UIColor(named: "SelectedCellBackground")
            cell.addSubview(borderTop)
            
            let borderBottom = UIView(frame: CGRect(x: 0, y: cell.frame.height, width: tableView.frame.width, height: borderWidth))
            borderBottom.backgroundColor = UIColor(named: "SelectedCellBackground")
            cell.addSubview(borderBottom)
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSegmentCell", for: indexPath) as! SegmentTableViewCell
            cell.segmentCallback = selectFilter
            cell.backgroundColor = nil
            return cell
        default:
            return UITableViewCell()
        }
    }
}
