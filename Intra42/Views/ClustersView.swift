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
    let stackPosX: UIStackView
    
    weak var delegate: ClustersViewDelegate?
    var locations: [String: ClusterPerson]?
    var data: [ClusterData] = []
    var userImages: [Int: UIImage] = [:]
    var imageTasks: [URLSessionDataTask] = []
    var currentPos: Int = 0
    
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
        currentPos = pos
        
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
                let host = "\(post.host ?? "")\(cluster.hostSuffix ?? "")"
                view.host = host
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
    
    private func _setClusterPostOn(post: ClusterPost, withPerson person: ClusterPerson) {
        let id = person.id
        let name = person.name
        
        post.delegate = delegate
        post.userId = id
        post.userName = name
        post.imageView.layer.masksToBounds = false
        post.imageView.layer.cornerRadius = 15
        post.imageView.clipsToBounds = true
        if let image = userImages[id] {
            post.imageView.image = image
        } else {
            _setUserImageOn(view: post.imageView, login: name, id: id)
        }
        if FriendDataManager.shared.hasFriend(withId: id) {
            post.contentView.backgroundColor = UIColor.green
        } else if id == API42Manager.shared.userProfile?.userId {
            post.contentView.backgroundColor = UIColor.orange
        }
    }
    
    private func _setUserImageOn(view: UIImageView, login: String, id: Int) {
        let urlString = "https://cdn.intra.42.fr/users/small_\(login).jpg"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error == nil, let imgData = data, let image = UIImage(data: imgData) {
                    DispatchQueue.main.async {
                        view.image = image
                        self.userImages.updateValue(image, forKey: id)
                    }
                } else if response != nil {
                    if let err = error {
                        print("Image Error: \(err)")
                    }
                    DispatchQueue.main.async {
                        if let image = UIImage(named: "42_default") {
                            view.image = image
                            self.userImages.updateValue(image, forKey: id)
                        }
                    }
                }
            }
            task.resume()
            self.imageTasks.append(task)
        }
    }
    
    func changePosition(to pos: Int) {
        _setupCluster(forPos: pos)
        setupLocations()
    }
    
    func setupLocations() {
        if let users = locations {
            for case let stackPosY as UIStackView in stackPosX.arrangedSubviews {
                for case let post as ClusterPost in stackPosY.arrangedSubviews {
                    let location = post.host
                    if let user = users[location] {
                        _setClusterPostOn(post: post, withPerson: user)
                    }
                }
            }
        }
    }
    
    func clearUserImages() {
        for case let stackPosY as UIStackView in stackPosX.arrangedSubviews {
            for case let post as ClusterPost in stackPosY.arrangedSubviews where post.userId != 0 {
                post.imageView.image = UIImage(named: "monitor")
            }
        }
    }
}
