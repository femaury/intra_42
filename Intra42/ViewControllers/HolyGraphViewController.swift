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
    let contentView = UIView()
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fixes navbar background color bug in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }

        activityIndicator.frame = scrollView.frame
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        scrollView.isUserInteractionEnabled = false
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor(hexRGB: "#041923")
    }
    
    func drawHolyGraph(forUser user: String, campusId: Int, cursusId: Int) {
        self.title = user
        API42Manager.shared.getProjectCoordinates(forUser: user, campusId: campusId, cursusId: cursusId) { projects in
            DispatchQueue.main.async {
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
                    
                    let kind = project["kind"].stringValue
                    let title = project["name"].stringValue
                    let view = HolyGraphView(kind: kind, state: state, position: pos, title: title)
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
                self.scrollView.contentOffset = CGPoint(x: newContentOffset, y: 0)
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
            color = UIColor.darkGray.cgColor
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
