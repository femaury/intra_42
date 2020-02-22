//
//  File.swift
//  Intra42
//
//  Created by Felix Maury on 19/02/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ClustersViewDelegate: class {
    var selectedCell: UserProfileCell? { get set }
    
    func performSegue(withIdentifier: String, sender: Any?)
    func present(_: UIViewController, animated: Bool, completion: (() -> Void)?)
}

class ClustersView: UIView {
    weak var delegate: ClustersViewDelegate?
    var locations: [String: ClusterPerson]?
    var data: [ClusterData] = []
    
    init(withData data: [ClusterData], forPos pos: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: 400, height: 55))
        self.data = data
        _setupCluster(forPos: pos)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func _getPostNumber(forHost host: String?) -> String? {
        guard let host = host else { return nil }
        let numbers = host.components(separatedBy: CharacterSet.decimalDigits.inverted)
        return numbers.last
    }
    
    private func _setupCluster(forPos pos: Int) {
        for sub in subviews {
            sub.removeFromSuperview()
        }
        guard data.count > pos else { return }
        let stackPosX = UIStackView()
        stackPosX.axis = .horizontal
        
        let cluster = data[pos]
        let map = cluster.map
        for column in map {
            let stackPosY = UIStackView()
            stackPosY.axis = .vertical
            for post in column {
                let view = ClusterPost()
                view.isUserInteractionEnabled = false
                switch post.kind {
                case "USER":
                    view.isUserInteractionEnabled = true
                    view.delegate = delegate
                    view.setAsUser(withPos: _getPostNumber(forHost: post.host))
                case "WALL":
                    view.setAsWall()
                case "LABEL":
                    view.setAsLabel(withText: post.label)
                default:
                    view.setAsEmpty()
                }
                stackPosY.addArrangedSubview(view)
            }
            stackPosX.addArrangedSubview(stackPosY)
        }
        addSubview(stackPosX)
    }
    
    func changePosition(to pos: Int) {
        _setupCluster(forPos: pos)
        if let users = locations {
            setupLocations(withUsers: users)
        }
    }
    
    func setupLocations(withUsers users: [String: ClusterPerson]) {
        locations = users
    }
    
    func clearUserImages() {
        guard let stackPosX = subviews.last as? UIStackView else { return }
        for case let stackPosY as UIStackView in stackPosX.arrangedSubviews {
            for case let post as ClusterPost in stackPosY.arrangedSubviews {
                post.imageView.image = nil
            }
        }
    }
}
