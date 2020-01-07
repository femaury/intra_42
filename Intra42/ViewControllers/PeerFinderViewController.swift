//
//  PeerFinderViewController.swift
//  Intra42
//
//  Created by Felix Maury on 07/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class PeerFinderViewController: UITableViewController {

    let filters = ["Validated", "Looking for Team", "In Progress"]
    var selectedCursus: (id: Int, name: String) = (0, "None")
    var selectedProject: ProjectItem = ProjectItem(name: "None", slug: "", id: 0)
    var selectedFilters: [Int] = [0]
    var selectedType: PeerListType?
    var searchButtonEnabled = false { didSet { tableView.reloadData() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func selectedRowAt(indexPath: IndexPath) {
        let contains = selectedFilters.contains(indexPath.row)
        if contains && selectedFilters.count > 1 {
            print("REMOVING")
            selectedFilters.remove(at: selectedFilters.firstIndex(of: indexPath.row)!)
            print(selectedFilters)
        } else if !contains {
            print("ADDING")
            selectedFilters.append(indexPath.row)
            print(selectedFilters)
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "CURSUS"
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
            return "You must choose a cursus to see its available projects."
        case 1:
            return "Projects are saved locally, swipe down in the list to check if they are up to date."
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && selectedCursus.id == 0 {
            return nil
        }
        return indexPath.section == 3 ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedType = .cursus
        case 1:
            selectedType = .project
        case 2:
            selectedType = .filter
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "optionCell")
        cell.accessoryType = .disclosureIndicator

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = selectedCursus.name
        case 1:
            cell.textLabel?.text = selectedProject.name
            cell.detailTextLabel?.text = selectedProject.slug
        case 2:
            var text: String
            if selectedFilters.isEmpty {
                text = "None"
            } else {
                text = selectedFilters.map { filters[$0] } .joined(separator: ", ")
            }
            cell.textLabel?.text = text
        default:
            break
        }

        cell.layer.borderWidth = 1.0 / UIScreen.main.scale
        cell.layer.borderColor = UIColor(named: "SelectedCellBackground")?.cgColor
        
        return cell
    }
}
