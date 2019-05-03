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
    let isCorrector: Bool
    let corrector: String
    let correctee: String
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
        
//        API42Manager.shared.request(url: "https://api.intra.42.fr/v2/achievements?page[size]=100") { (data) in
//            print(data ?? "No data")
//            print(data?.arrayValue.count ?? "nil")
//            API42Manager.shared.request(url: "https://api.intra.42.fr/v2/achievements?page[number]=2&page[size]=100", completionHandler: { (data) in
//                print(data ?? "No data")
//                print(data?.arrayValue.count ?? "nil")
//            })
//        }
        API42Manager.shared.getScales { (scales) in
            for scale in scales.reversed() {
                let name = scale["scale"]["name"].stringValue
                var isCorrector = true
                let corrector = scale["corrector"].stringValue
                let correctee = scale["correcteds"].arrayValue[0]
                if correctee["id"].intValue == API42Manager.shared.userProfile?.userId {
                    isCorrector = false
                }
                let dateString = scale["begin_at"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                let date = dateFormatter.date(from: dateString) ?? Date()
                
                let correction = Correction(name: name, isCorrector: isCorrector, corrector: corrector, correctee: correctee["login"].stringValue, startDate: date)
                self.corrections.append(correction)
            }
            self.tableView.reloadData()
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
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return corrections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let correction = corrections[indexPath.row]
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "ScaleCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "ScaleCell")
        }
        
        var text: String
        if correction.isCorrector {
            text = "You will be evaluating \(correction.correctee) on \(correction.name)"
        } else {
            text = "You will be evaluated by \(correction.corrector) on \(correction.name)"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy HH:mm"
        let dateString = formatter.string(from: correction.startDate)
        
        cell.textLabel?.text = text + " on \(dateString)"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
//        cell.detailTextLabel?.text = dateString
//        cell.detailTextLabel?.numberOfLines = 0
//        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
}
