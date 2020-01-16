//
//  HolyGraphViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-11-29.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SwiftyJSON

class HolyGraphViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var contentView = UIView()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var user: String = String()
    var userId: Int = Int()
    var cursus: [(id: Int, name: String)] = []
    var campusId: Int = Int()
    var cursusId: Int = Int()
    
    var selectedProjectId: Int = Int()
    var selectedProjectState: String = String()
    var selectedProjectDuration: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keeps navbar background color black in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }

        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        scrollView.isUserInteractionEnabled = false
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor(hexRGB: "#041923")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectInfoSegue" {
            if let destination = segue.destination as? ProjectInfoViewController {
                API42Manager.shared.getProjectInfo(withId: selectedProjectId, forUser: userId, campusId: campusId) { (info) in
                    guard var info = info else {
                        destination.activityIndicator.hidesWhenStopped = false
                        destination.activityIndicator.stopAnimating()
                        destination.registerButton.isEnabled = false
                        return
                    }
                    let duration = self.selectedProjectDuration
                    info.duration = duration.prefix(1).capitalized + duration.dropFirst()
                    info.state = ProjectState(rawValue: self.selectedProjectState) ?? .unavailable
                    destination.info = info
                    destination.delegate = self
                    destination.setupController()
                }
                
            }
        } else if segue.identifier == "UserProjectSegue" {
            if let destination = segue.destination as? UserProjectController {
                API42Manager.shared.getTeam(forUserId: userId, projectId: selectedProjectId) { projectTeams in
                    destination.projectTeams = projectTeams
                    destination.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func changeCursus(_ sender: Any) {
        guard cursus.count > 0 else { return }
        let showCursusAction = UIAlertController(title: "Cursus", message: nil, preferredStyle: .actionSheet)
        for item in cursus {
            let actionItem = UIAlertAction(title: item.name, style: .default) { [weak self] (_) in
                guard let self = self else { return }
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.contentView.subviews.forEach({ $0.removeFromSuperview() })
                self.contentView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                self.contentView.removeFromSuperview()
                self.contentView = UIView()
                self.drawHolyGraph(forUser: self.user, campusId: self.campusId, cursusId: item.id)
            }
            if item.id == cursusId {
                actionItem.isEnabled = false
            }
            showCursusAction.addAction(actionItem)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        showCursusAction.addAction(cancel)
        present(showCursusAction, animated: true, completion: nil)
    }
    
    func reloadHolyGraph() {
        drawHolyGraph(forUser: user, campusId: campusId, cursusId: cursusId)
    }
    
    func drawHolyGraph(forUser user: String, campusId: Int, cursusId: Int) {
        title = user
        self.user = user
        self.campusId = campusId
        self.cursusId = cursusId
        
        API42Manager.shared.getProjectCoordinates(forUser: user, campusId: campusId, cursusId: cursusId) { projects in
            DispatchQueue.main.async {
                guard let projects = projects else {
                    print("Cookie unauthorized...")
                    let alertController = UIAlertController(
                        title: "Invalid Session Cookie",
                        message: "You need to relog to see the holy graph...",
                        preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Log out", style: .destructive) { _ in
                        API42Manager.shared.logoutUser()
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(action)
                    alertController.addAction(cancel)
                    self.present(alertController, animated: true)
                    return
                }
                guard !projects.isEmpty else {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                var maxX = self.view.frame.maxX
                var maxY = self.view.frame.maxY
                var minX: CGFloat = 50000
                var minY: CGFloat = 50000
                for project in projects {
                    let posX = CGFloat(project["x"].intValue)
                    let posY = CGFloat(project["y"].intValue)
                    let pos = CGPoint(x: posX, y: posY)
                    let state = project["state"].stringValue
                    let lines = project["by"].arrayValue
                    for line in lines {
                        let points = line["points"].arrayValue
                        guard points.count > 1 else { continue }
                        let pointOne = points[0].arrayValue
                        let pointTwo = points[1].arrayValue
                        let posOne = CGPoint(x: pointOne[0].intValue, y: pointOne[1].intValue)
                        let posTwo = CGPoint(x: pointTwo[0].intValue, y: pointTwo[1].intValue)
                        self.drawLineFrom(posOne, to: posTwo, ofState: state, inView: self.contentView)
                    }
                    
                    maxX = posX > maxX ? posX : maxX
                    minX = posX < minX ? posX : minX
                    maxY = posY > maxY ? posY : maxY
                    minY = posY < minY ? posY : minY
                    
                    let id = project["project_id"].intValue
                    let kind = project["kind"].stringValue
                    let title = project["name"].stringValue
                    let duration = project["duration"].stringValue
                    let view = HolyGraphView(cursus: cursusId, id: id, kind: kind, state: state, position: pos, title: title)
                    view.delegate = self
                    view.duration = duration
                    view.center = self.contentView.convert(self.contentView.center, from: view)
                    self.contentView.addSubview(view)
                }
                
                self.contentView.frame = CGRect(x: 0, y: 0, width: maxX + minX, height: maxY + minY)
                
                let minZoomScale = UIScreen.main.bounds.width / self.contentView.frame.width
                
                self.scrollView.addSubview(self.contentView)
                self.scrollView.contentSize = self.contentView.frame.size
                self.scrollView.minimumZoomScale = minZoomScale * 1.3
                self.scrollView.maximumZoomScale = 1.5
                self.scrollView.setZoomScale(minZoomScale * 1.3, animated: true)
                self.scrollView.isUserInteractionEnabled = true
                let newContentOffset = (self.contentView.frame.size.width / 2) - (self.scrollView.bounds.size.width / 2)
                self.scrollView.contentOffset = CGPoint(x: newContentOffset - 10, y: 0)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func drawLineFrom(_ start: CGPoint, to end: CGPoint, ofState state: String, inView view: UIView) {
        var color: CGColor?
        switch state {
        case "done":
            color = Colors.intraTeal?.cgColor
        case "available", "in_progress":
            color = UIColor.white.cgColor
        default:
            color = UIColor.gray.cgColor
        }

        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 8

        view.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
}
