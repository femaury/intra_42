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
        case looking
        case inProgress
        case validated
    }
    var selectedCampus: (id: Int, name: String) = (0, "None")
    var selectedCursus: (id: Int, name: String) = (0, "None")
    var selectedProject: ProjectItem = ProjectItem(name: "None", slug: "", id: 0)
    var selectedFilter: Filter = .looking
    var selectedType: PeerListType?
    var searchButtonEnabled = false { didSet { tableView.reloadData() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let id = API42Manager.shared.userProfile?.mainCampusId, let name = API42Manager.shared.userProfile?.mainCampusName {
            selectedCampus = (id, name)
            print("TTOTOTO")
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
            selectedFilter = .looking
        case 1:
            selectedFilter = .inProgress
        case 2:
            selectedFilter = .validated
        default:
            return
        }
    }
    
    func searchUsers() {
        let projectId = selectedProject.id
        let campusId = selectedCampus.id
        let url = API42Manager.shared.baseURL + "projects/\(projectId)/projects_users?filter[campus]=\(campusId)&page[size]=100"
        API42Manager.shared.request(url: url) { (data) in
            print("PROJECT USERS \(data?.arrayValue.count)")
            print(data)
        }
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
            cell.delegate = self
            cell.backgroundColor = nil
            return cell
        }

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "campusCell")
                ?? UITableViewCell(style: .value1, reuseIdentifier: "campusCell")
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Campus"
                cell.detailTextLabel?.text = selectedCampus.name
            } else {
                cell.textLabel?.text = "Cursus"
                cell.detailTextLabel?.text = selectedCursus.name
            }
            cell.accessoryType = .disclosureIndicator
            cell.layer.borderWidth = 1.0 / UIScreen.main.scale
            cell.layer.borderColor = UIColor(named: "SelectedCellBackground")?.cgColor
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell")
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: "projectCell")
            
            cell.textLabel?.text = selectedProject.name
            cell.detailTextLabel?.text = selectedProject.slug
            cell.accessoryType = .disclosureIndicator
            cell.layer.borderWidth = 1.0 / UIScreen.main.scale
            cell.layer.borderColor = UIColor(named: "SelectedCellBackground")?.cgColor
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSegmentCell", for: indexPath) as! SegmentTableViewCell
            cell.segmentCallback = selectFilter
            return cell
        default:
            return UITableViewCell()
        }
    }
}
