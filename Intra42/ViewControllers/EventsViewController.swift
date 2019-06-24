//
//  ProjectsViewController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

// TODO: Fix buggly refresh control...
class EventsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var segmentedControl = UISegmentedControl(items: ["All Events", "My Events"])
    let searchController = UISearchController(searchResultsController: nil)
    
    var events: [Event] = []
    var filteredEvents: [Event] = []
    var myEvents: [Event] = []
    var myFilteredEvents: [Event] = []
    var isLoadingEvents = true
    var isLoadingMyEvents = true
    var selectedEventCell: EventCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search events..."
        searchController.searchBar.scopeButtonTitles = ["All",
                                                        "Event",
                                                        "Asso",
                                                        "Hack",
                                                        "Conf",
                                                        "Others"]
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .black
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        populateAllEventsTable()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.populateMyEventsTable()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if searchController.isActive {
            // TODO: Fix Hack: Keeps cells from going underneath search controller when
            // coming back from detail controller
            tableView.contentInset = UIEdgeInsets(top: 150, left: 0, bottom: 0, right: 0)
        }
    }
    
    func populateAllEventsTable() {
        guard
            let campusId = API42Manager.shared.userProfile?.mainCampusId,
            let cursusId = API42Manager.shared.userProfile?.mainCursusId
        else {
            tableView.refreshControl?.endRefreshing()
            self.isLoadingEvents = false
            return
        }
        events = []
        API42Manager.shared.getFutureEvents(forCampusId: campusId, cursusId: cursusId) { (events) in
            for event in events.reversed() {
                let newEvent = Event(event: event)
                self.events.append(newEvent)
            }
            self.isLoadingEvents = false
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func populateMyEventsTable() {
        guard let userId = API42Manager.shared.userProfile?.userId else {
            tableView.refreshControl?.endRefreshing()
            self.isLoadingMyEvents = false
            return
        }
        myEvents = []
        API42Manager.shared.getFutureEvents(forUserId: userId) { (events) in
            for event in events.reversed() {
                let newEvent = Event(event: event)
                self.myEvents.append(newEvent)
            }
            self.isLoadingMyEvents = false
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    @objc func refreshTable() {
        if segmentedControl.selectedSegmentIndex == 0 {
            populateAllEventsTable()
        } else {
            populateMyEventsTable()
        }
    }
}

// MARK: - Segment Control Functions

extension EventsViewController {
    
    @objc func segmentValueChanged(segment: UISegmentedControl) {
        tableView.reloadData()
    }
}

// MARK: - Search Controller

extension EventsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let searchText = searchBar.text {
            if let scope = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] {
                filterEvents(forSearch: searchText, scope: scope)
            } else {
                filterEvents(forSearch: searchText)
            }
        }
    }
    
    func filterEvents(forSearch search: String, scope: String = "All") {
        let filterClosure = { (event: Event) -> Bool in
            var kind: EventKind = .event
            switch scope {
            case "Event":
                kind = .event
            case "Asso":
                kind = .association
            case "Hack":
                kind = .hackathon
            case "Conf":
                kind = .conference
            default:
                kind = .extern
            }
            var match = scope == "All" || event.kind == kind
            if kind == .extern && scope != "All" {
                if event.kind == .extern || event.kind == .meetup || event.kind == .workshop {
                    match = true
                }
            }
            
            if self.searchBarIsEmpty() {
                return match
            } else {
                return match && event.name.lowercased().contains(search.lowercased())
            }
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            filteredEvents = events.filter(filterClosure)
        } else {
            myFilteredEvents = myEvents.filter(filterClosure)
        }
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}

extension EventsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let search = searchBar.text, let scope = searchBar.scopeButtonTitles?[selectedScope] {
            filterEvents(forSearch: search, scope: scope)
        }
    }
}

// MARK: - Table View Delegate & Data Source

extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEventCell = tableView.cellForRow(at: indexPath) as? EventCell
        performSegue(withIdentifier: "EventSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventSegue" {
            guard let eventCell = selectedEventCell else { return }
            let destination = segue.destination as! EventDetailController
            destination.event = eventCell.event
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            if isFiltering() {
                return filteredEvents.count
            }
            return events.count > 0 ? events.count : 1
        } else {
            if isFiltering() {
                return myFilteredEvents.count
            }
            return myEvents.count > 0 ? myEvents.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if events.count > 0 && segmentedControl.selectedSegmentIndex == 0 {
            return 100
        } else if myEvents.count > 0 && segmentedControl.selectedSegmentIndex == 1 {
            return 100
        }
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedSection = segmentedControl.selectedSegmentIndex
        if (events.count > 0 && selectedSection == 0) || (myEvents.count > 0 && selectedSection == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
            if selectedSection == 0 {
                if isFiltering() {
                    cell.event = filteredEvents[indexPath.row]
                } else {
                    cell.event = events[indexPath.row]
                }
            } else {
                if isFiltering() {
                    cell.event = myFilteredEvents[indexPath.row]
                } else {
                    cell.event = myEvents[indexPath.row]
                }
            }
            return cell
        } else {
            var messageText = ""
            if selectedSection == 0 && isLoadingEvents == false {
                messageText = "There doesn't seem to be anything happening at your campus..."
            } else if selectedSection == 1 && isLoadingMyEvents == false {
                messageText = "You are not subscribed to any events..."
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingIndicatorCell") {
                    return cell
                }
            }
            var cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
            }
            cell?.textLabel?.text = messageText
            cell?.textLabel?.textAlignment = .center
            return cell!
        }
    }
}
