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
    
    let stackPosX: UIStackView
    
    init(withData data: [ClusterData], forPos pos: Int, width: Int, height: Int) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        stackPosX = UIStackView(frame: frame)
        stackPosX.axis = .horizontal
        stackPosX.alignment = .fill
        stackPosX.distribution = .fillEqually
        super.init(frame: frame)
        self.data = data
        addSubview(stackPosX)
        _setupCluster(forPos: pos)
    }
    
    override init(frame: CGRect) {
        stackPosX = UIStackView(frame: frame)
        stackPosX.axis = .horizontal
        stackPosX.alignment = .fill
        stackPosX.distribution = .fillEqually
        super.init(frame: frame)
        addSubview(stackPosX)
    }
    
    required init?(coder aDecoder: NSCoder) {
        stackPosX = UIStackView()
        super.init(coder: aDecoder)
    }
    
    private func _getPostNumber(forHost host: String?) -> String? {
        guard let host = host else { return nil }
        let numbers = host.components(separatedBy: CharacterSet.decimalDigits.inverted)
        return numbers.last
    }
    
    private func _setupCluster(forPos pos: Int) {
        for sub in stackPosX.arrangedSubviews {
            sub.removeFromSuperview()
        }
        guard data.count > pos else { return }
        
        let cluster = data[pos]
        let map = cluster.map
        for column in map {
            let stackPosY = UIStackView()
            stackPosY.axis = .vertical
            stackPosY.alignment = .fill
            stackPosY.distribution = .fillEqually
            
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
        
        setNeedsLayout()
        layoutIfNeeded()
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
        for case let stackPosY as UIStackView in stackPosX.arrangedSubviews {
            for case let post as ClusterPost in stackPosY.arrangedSubviews {
                post.imageView.image = nil
            }
        }
    }
}
