//
//  SideMenuController.swift
//  Intra42
//
//  Created by Felix Maury on 26/03/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit
import SafariServices

class SideMenuController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuTrailing: NSLayoutConstraint!
    
    weak var menuNavigationController: UINavigationController?
    var snapshotForBackground: UIImage?
    let items: [(title: String, image: UIImage?)] = [
        ("Projects", UIImage(named: "briefcase")),
        ("Forums", UIImage(named: "collaboration")),
        ("Coalitions", UIImage(named: "bookmark_ribbon")),
        ("Achievements", UIImage(named: "trophy")),
        ("Peer Finder", UIImage(named: "meeting")),
        ("About", UIImage(named: "info")),
        ("Settings", UIImage(named: "settings")),
        ("Logout", UIImage(named: "shutdown"))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.image = snapshotForBackground
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        dimmerView.addGestureRecognizer(tapGesture)
        
        // Hide menu at first
        dimmerView.alpha = 0.0
        if let safeAreaWidth = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.width {
            menuTrailing.constant = safeAreaWidth
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showMenu()
    }
    
    // MARK: - Animations
    
    private func showMenu() {
        
        self.view.layoutIfNeeded()
        if let safeAreaWidth = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.width {
            menuTrailing.constant = safeAreaWidth * 0.45
        }
        
        let showMenu = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
            self.view.superview?.layoutIfNeeded()
        })
        showMenu.addAnimations {
            self.dimmerView.alpha = 0.7
        }
        showMenu.startAnimation()
    }
    
    private func dismissMenu() {
        
        self.view.layoutIfNeeded()
        if let safeAreaWidth = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.width {
            menuTrailing.constant = safeAreaWidth
        }
        let hideMenu = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
            self.view.superview?.layoutIfNeeded()
        })
        hideMenu.addAnimations {
            self.dimmerView.alpha = 0.0
        }
        hideMenu.addCompletion { position in
            if position == .end {
                if self.presentingViewController != nil {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
        hideMenu.startAnimation()
    }
    
    // MARK: - Actions
    
    @objc func tapHandler(gesture: UIGestureRecognizer) {
        dismissMenu()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectsSegue" {
            if let destination = segue.destination as? HolyGraphViewController {
                if let user = API42Manager.shared.userProfile?.username,
                    let userId = API42Manager.shared.userProfile?.userId,
                    let campusId = API42Manager.shared.userProfile?.mainCampusId,
                    let cursusId = API42Manager.shared.userProfile?.mainCursusId,
                    let cursus = API42Manager.shared.userProfile?.cursusList {
                    destination.cursus = cursus
                    destination.userId = userId
                    destination.drawHolyGraph(forUser: user, campusId: campusId, cursusId: cursusId)
                }
            }
        }
    }
}

// MARK: - Table View

extension SideMenuController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "HolyGraphViewController") as? HolyGraphViewController,
                let user = API42Manager.shared.userProfile?.username,
                let userId = API42Manager.shared.userProfile?.userId,
                let campusId = API42Manager.shared.userProfile?.mainCampusId,
                let cursusId = API42Manager.shared.userProfile?.mainCursusId,
                let cursus = API42Manager.shared.userProfile?.cursusList {
                controller.cursus = cursus
                controller.userId = userId
                controller.drawHolyGraph(forUser: user, campusId: campusId, cursusId: cursusId)
                self.dismiss(animated: false)
                menuNavigationController?.show(controller, sender: nil)
            }
        case 1:
            let urlString = "https://stackoverflow.com/c/42network"
            if let url = URL(string: urlString) {
                let safariVC = SFSafariViewController(url: url)
                safariVC.modalPresentationStyle = .overFullScreen
                
                self.present(safariVC, animated: true, completion: nil)
            }
        case 2:
            let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "CoalitionsViewController")
            dismiss(animated: false)
            menuNavigationController?.show(controller, sender: nil)
        case 3:
            let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "AchievementsController")
            dismiss(animated: false)
            menuNavigationController?.show(controller, sender: nil)
        case 4:
            let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PeerFinderViewController")
            dismiss(animated: false)
            menuNavigationController?.show(controller, sender: nil)
        case 5:
            let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "AboutViewController")
            dismiss(animated: false)
            menuNavigationController?.show(controller, sender: nil)
        case 6:
            let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
            dismiss(animated: false)
            menuNavigationController?.show(controller, sender: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PagesCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "PagesCell")
        
        cell.imageView?.image = items[indexPath.row].image
        cell.textLabel?.text = items[indexPath.row].title
        if indexPath.row == 4 {
            let borderBottom = UIView(frame: CGRect(x: 0, y: 49, width: tableView.frame.width, height: 1))
            borderBottom.backgroundColor = .black
            if #available(iOS 13.0, *) {
                borderBottom.backgroundColor = .label
            }
            cell.addSubview(borderBottom)
        } else if indexPath.row == items.endIndex - 1 {
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = .red
            cell.textLabel?.textColor = .red
        }
        
        return cell
    }
}
