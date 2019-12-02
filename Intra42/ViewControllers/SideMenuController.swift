//
//  SideMenuController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-06.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SafariServices
import SideMenu

class SideMenuController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    
    let items: [(title: String, image: UIImage?)] = [
        ("Projects", UIImage(named: "briefcase")),
        ("Videos", UIImage(named: "movie")),
        ("Forums", UIImage(named: "collaboration")),
        ("Coalitions", UIImage(named: "bookmark_ribbon")),
        ("Achievements", UIImage(named: "trophy")),
        ("About", UIImage(named: "info")),
        ("Settings", UIImage(named: "settings")),
        ("Logout", UIImage(named: "shutdown"))
    ]
    let disabledItems: [Int] = [1] // Unfinished pages

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fixes navbar background color bug in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }
        
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectsSegue" {
            if let destination = segue.destination as? HolyGraphViewController {
                if let user = API42Manager.shared.userProfile?.username,
                    let campusId = API42Manager.shared.userProfile?.mainCampusId,
                    let cursusId = API42Manager.shared.userProfile?.mainCursusId,
                    let cursus = API42Manager.shared.userProfile?.cursusList {
                    destination.cursus = cursus
                    destination.drawHolyGraph(forUser: user, campusId: campusId, cursusId: cursusId)
                }
            }
        }
    }
}

extension SideMenuController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if disabledItems.contains(indexPath.row) {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "ProjectsSegue", sender: self)
        case 1:
//            let url = API42Manager.shared.baseURL + "attachments?page[size]=100"
//            API42Manager.shared.request(url: url) { (data) in
//                print(data)
//            }
            performSegue(withIdentifier: "VideosSegue", sender: self)
        case 2:
            let urlString = "https://stackoverflow.com/c/42network"
            if let url = URL(string: urlString) {
                let safariVC = SFSafariViewController(url: url)
                safariVC.modalPresentationStyle = .overFullScreen
                
                self.present(safariVC, animated: true, completion: nil)
            }
        case 3:
            let url = API42Manager.shared.baseURL + "campus?page[size]=100"
            API42Manager.shared.request(url: url) { (data) in
                print(data)
            }
//            performSegue(withIdentifier: "CoalitionsSegue", sender: self)
        case 4:
            performSegue(withIdentifier: "AchievementsSegue", sender: self)
        case 5:
            performSegue(withIdentifier: "AboutSegue", sender: self)
        case 6:
            performSegue(withIdentifier: "SettingsSegue", sender: self)
        case 7:
            API42Manager.shared.logoutUser()
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PagesCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "PagesCell")
        }
        cell?.imageView?.image = items[indexPath.row].image
        cell?.textLabel?.text = items[indexPath.row].title
        if indexPath.row == 4 {
            let borderBottom = UIView(frame: CGRect(x: 0, y: 49, width: tableView.frame.width, height: 1))
            borderBottom.backgroundColor = .black
            if #available(iOS 13.0, *) {
                borderBottom.backgroundColor = .label
            }
            cell?.addSubview(borderBottom)
        } else if indexPath.row == items.endIndex - 1 {
            cell?.imageView?.image = cell?.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell?.imageView?.tintColor = .red
            cell?.textLabel?.textColor = .red
        }
        if disabledItems.contains(indexPath.row) {
            cell?.selectionStyle = .none
            cell?.textLabel?.isEnabled = false
            cell?.imageView?.image = cell?.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell?.imageView?.tintColor = .gray
        }
        return cell!
    }
}
