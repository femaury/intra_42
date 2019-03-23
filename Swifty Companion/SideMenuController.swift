//
//  SideMenuController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-06.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class SideMenuController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let items: [(title: String, image: UIImage?)] = [
        ("Projects", UIImage(named: "briefcase")),
        ("Videos", UIImage(named: "movie")),
        ("Forums", UIImage(named: "collaboration")),
        ("Achievements", UIImage(named: "trophy")),
        ("About", UIImage(named: "info")),
        ("Logout", UIImage(named: "shutdown"))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let logoView = UIImageView(image: UIImage(named: "42_logo"))
        logoView.contentMode = .scaleAspectFit
        navigationItem.titleView = logoView
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

extension SideMenuController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "ProjectsSegue", sender: self)
        case 1:
            performSegue(withIdentifier: "VideosSegue", sender: self)
        case 2:
            performSegue(withIdentifier: "ForumsSegue", sender: self)
        case 3:
            performSegue(withIdentifier: "AchievementsSegue", sender: self)
        case 4:
            performSegue(withIdentifier: "AboutSegue", sender: self)
        case 5:
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
        if indexPath.row == 3 {
            let borderBottom = UIView(frame: CGRect(x: 0, y: 49, width: tableView.frame.width, height: 1))
            borderBottom.backgroundColor = UIColor.black
            cell?.addSubview(borderBottom)
        }
        return cell!
    }
}
