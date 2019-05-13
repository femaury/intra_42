//
//  CorrectionsViewController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-28.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

struct Correction {
    let name: String
    let teamName: String
    let projectId: Int
    let repoURL: String
    let isCorrector: Bool
    let corrector: (id: Int, login: String)
    let correctees: [(id: Int, login: String)]
    let startDate: Date
}

class CorrectionsViewController: UIViewController {

    lazy var searchBar = UISearchBar()
    @IBOutlet weak var tableView: UITableView!
    
    var corrections: [Correction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        API42Manager.shared.getScales { (scales) in
            print(scales)
            for scale in scales.reversed() {
                let team = scale["team"]
                let members = team["users"].arrayValue
                let projectId = team["project_id"].intValue
                let repoURL = team["repo_url"].stringValue
                let teamName = team["name"].stringValue
                
                var correctees: [(id: Int, login: String)] = []
                var isCorrector = true
                for member in members {
                    let correcteeLogin = member["login"].stringValue
                    let correcteeId = member["id"].intValue
                    if correcteeId == API42Manager.shared.userProfile?.userId {
                        isCorrector = false
                    }
                    if member["leader"].boolValue {
                        correctees.insert((correcteeId, correcteeLogin), at: 0)
                    } else {
                        correctees.append((correcteeId, correcteeLogin))
                    }
                }
                
                var corrector: (id: Int, login: String) = (0, "unknown")
                if scale["corrector"].string == nil {
                    let corr = scale["corrector"]
                    corrector = (corr["id"].intValue, corr["login"].stringValue)
                }
                
                let dateString = scale["begin_at"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                let date = dateFormatter.date(from: dateString) ?? Date()
                
                API42Manager.shared.getProject(withId: projectId, completionHandler: { (data) in
                    var name = "Unknown Project"
                    if let data = data {
                        name = data["name"].stringValue
                    }

                    let correction = Correction(
                        name: name,
                        teamName: teamName,
                        projectId: projectId,
                        repoURL: repoURL,
                        isCorrector: isCorrector,
                        corrector: corrector,
                        correctees: correctees,
                        startDate: date)
                    self.corrections.append(correction)
                    self.tableView.reloadData()
                })
            }
        }
    }

    @objc func tapHandler(gesture: UIGestureRecognizer) {
        self.searchBar.resignFirstResponder()
    }
}

// MARK: - Prepare for segue

extension CorrectionsViewController: SearchResultsDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegue" {
            if let destination = segue.destination as? SearchResultsController {
                showSearchResultsController(atDestination: destination)
            }
        }
    }
}

// MARK: - Search Bar Delegate

extension CorrectionsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            performSegue(withIdentifier: "SearchResultsSegue", sender: self)
        }
        searchBar.resignFirstResponder()
    }
}

// MARK: - Table View Delegate / Data Source

extension CorrectionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return corrections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let correction = corrections[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScaleOneCell") as! ScaleOneCell
        cell.setupCell(correction: correction)
        return cell
    }
}
