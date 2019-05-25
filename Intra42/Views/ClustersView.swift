//
//  ClustersView.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-11.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

/*
                                                         Stack Views Map
 
               Left Rows                                   Center Rows                                  Right Rows
 [                                                                                          [
 R13: [P01,P02,P03,P04,P05,P06,P07],       [                                                R13: [P08,P09,P10,P11,P12,P13,P14],
 R12: [P01,P02,P03,P04,P05,P06,P07],       R12: [P08,P09,P10,P11,P12,P13,P14,P15,P16],      R12: [P17,P18,P19,P20,P21,P22,P23],
 R11: [P01,P02,P03,P04,P05,P06,P07],       R11: [P08,P09,P10,P11,P12,P13,P14,P15,P16],      R11: [P17,P18,P19,P20,P21,P22,P23],
 R10: [P01,P02,P03,P04,P05,P06,P07],       R10: [P08,P09,P10,P11,P12,P13,P14,P15,P16],      R10: [P17,P18,P19,P20,P21,P22,P23],
 R9:  [P01,P02,P03,P04,P05,P06],           R9:  [---,P07,P08,P09,P10,P11,P12,P13,---],      R9:  [P14,P15,P16,P17,P18,P19,P20],
 R8:  [P01,P02,P03,P04,P05,P06],           R8:  [---,P07,P08,P09,P10,P11,P12,P13,P14],      R8:  [P15,P16,P17,P18,P19,P20,P21],
 R7:  [P01,P02,P03,P04,P05,P06],           R7:  [P07,P08,P09,P10,P11,P12,P13,P14,P15],      R7:  [P16,P17,P18,P19,P20,P21,P22],
 R6:  [P01,P02,P03,P04,P05,P06,P07],       R6:  [---,P08,P09,P10,P11,P12,P15,P16,---],      R6:  [P17,P18,P19,P20,P21,P22,P23],
 R5:  [P01,P02,P03,P04,P05,P06,P07],       R5:  [P08,P09,P10,P11,P12,P13,P14,P15,P16],      R5:  [P17,P18,P19,P20,P21,P22,P23],
 R4:  [P01,P02,P03,P04,P05,P06,P07],       R4:  [P08,P09,P10,P11,P12,P13,P14,P15,P16],      R4:  [P17,P18,P19,P20,P21,P22,P23],
 R3:  [P01,P02,P03,P04,P05,P06,P07],       R3:  [---,P08,P09,P10,P11,P12,P15,P16,---],      R3:  [P17,P18,P19,P20,P21,P22,P23],
 R2:  [P01,P02,P03,P04,P05,P06,P07],       R2:  [P08,P09,P10,P11,P12,P13,P14,P15,P16]       R2:  [P17,P18,P19,P20,P21,P22,P23],
 R1:  [P01,P02,P03,P04,P05,P06,P07]        ]                                                R1:  [P08,P09,P10,P11,P12,P13,P14]
 ]                                                                                          ]
 
 NOTE:  This map is innacurate for clusters E2 and E3
        -- Add R7P07 in Left Rows
        -- Remove R6P17 and R5P17 (and change post numbers accordingly)
*/

import UIKit

struct ClusterPerson {
    var id: Int
    var name: String
}

class ClustersView: UIView {

    weak var delegate: ClustersViewController?
    
    let defaultImage = UIImage(named: "monitor")
    var userImages: [Int: UIImage] = [:]
    var imageTasks: [URLSessionDataTask] = []
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var leftRows: UIStackView!
    @IBOutlet weak var centerRows: UIStackView!
    @IBOutlet weak var rightRows: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("Cluster", owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func setupStackViews(floor: Int) {
        let leftRow7 = leftRows.arrangedSubviews[6] as! UIStackView
        let rightRow6 = rightRows.arrangedSubviews[7] as! UIStackView
        let rightRow5 = rightRows.arrangedSubviews[8] as! UIStackView
        if floor == 1 {
            if leftRow7.arrangedSubviews.count == 7 {
                let remove = leftRow7.arrangedSubviews.last as! ClusterPost
                print(remove.numberLabel.text ?? "No number found")
                leftRow7.removeArrangedSubview(remove)
            }
            if rightRow6.arrangedSubviews.count == 6 {
                rightRow6.addArrangedSubview(ClusterPost())
                rightRow5.addArrangedSubview(ClusterPost())
            }
        } else if floor == 2 || floor == 3 {
            if leftRow7.arrangedSubviews.count == 6 {
                leftRow7.addArrangedSubview(ClusterPost())
            }
            if rightRow6.arrangedSubviews.count > 6 {
                let remove = rightRow6.arrangedSubviews.first as! ClusterPost
                rightRow6.removeArrangedSubview(remove)
                let remove2 = rightRow5.arrangedSubviews.first as! ClusterPost
                rightRow5.removeArrangedSubview(remove2)
            }
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func setupCluster(floor: Int, cluster: [String: ClusterPerson]) {
        setupStackViews(floor: floor)
        if userImages.count > 1000 { userImages = [:] } // Cleanup dictionary
        for task in imageTasks where task.state == .running { // Cancel all image downloads
            task.cancel()
        }
        imageTasks = []
        
        var rowIndex = 13, postIndex = 1
        for case let row as UIStackView in leftRows.arrangedSubviews {
            postIndex = 1
            for case let post as ClusterPost in row.arrangedSubviews {
                let location = "e\(floor)r\(rowIndex)p\(postIndex)"
                post.numberLabel.text = String(postIndex)
                if let person = cluster[location] {
                    setClusterPostOn(post: post, withPerson: person)
                }
                postIndex += 1
            }
            rowIndex -= 1
        }
        rowIndex = 12
        for case let row as UIStackView in centerRows.arrangedSubviews {
            postIndex = 8
            if rowIndex == 9 || rowIndex == 8 || (rowIndex == 7 && floor == 1) { postIndex -= 1 }
            for case let post as ClusterPost in row.arrangedSubviews {
                if post.tag == ClusterPost.NoPostTag {
                    post.imageView.backgroundColor = UIColor.black
                    continue
                }
                
                let location = "e\(floor)r\(rowIndex)p\(postIndex)"
                post.numberLabel.text = String(postIndex)
                if let person = cluster[location] {
                    setClusterPostOn(post: post, withPerson: person)
                }
                postIndex += 1
            }
            rowIndex -= 1
        }
        rowIndex = 13
        for case let row as UIStackView in rightRows.arrangedSubviews {
            postIndex = 17
            
            if rowIndex == 9 {
                postIndex = 14
            } else if rowIndex == 8 || rowIndex == 6 || rowIndex == 3 {
                postIndex = 15
            } else if rowIndex == 7 && floor == 1 {
                postIndex = 16
            } else if rowIndex == 13 || rowIndex == 1 {
                postIndex = 8
            }
            
            for case let post as ClusterPost in row.arrangedSubviews {
                let location = "e\(floor)r\(rowIndex)p\(postIndex)"
                post.numberLabel.text = String(postIndex)
                if let person = cluster[location] {
                    setClusterPostOn(post: post, withPerson: person)
                }
                postIndex += 1
            }
            rowIndex -= 1
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    func setClusterPostOn(post: ClusterPost, withPerson person: ClusterPerson) {
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
            setUserImageOn(view: post.imageView, login: name, id: id)
        }
        if FriendDataManager.shared.hasFriend(withId: id) {
            post.contentView.backgroundColor = UIColor.green
        } else if id == API42Manager.shared.userProfile?.userId {
            post.contentView.backgroundColor = UIColor.orange
        }
    }
    
    func setUserImageOn(view: UIImageView, login: String, id: Int) {
        let urlString = "https://cdn.intra.42.fr/users/medium_\(login).jpg"
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
    
    func clearUserImages() {
        for case let row as UIStackView in leftRows.arrangedSubviews {
            for case let post as ClusterPost in row.arrangedSubviews {
                post.contentView.backgroundColor = UIColor.white
                post.imageView.layer.cornerRadius = 0
                post.imageView.image = defaultImage
            }
        }
        for case let row as UIStackView in centerRows.arrangedSubviews {
            for case let post as ClusterPost in row.arrangedSubviews {
                post.contentView.backgroundColor = UIColor.white
                post.imageView.layer.cornerRadius = 0
                post.imageView.image = defaultImage
            }
        }
        for case let row as UIStackView in rightRows.arrangedSubviews {
            for case let post as ClusterPost in row.arrangedSubviews {
                post.contentView.backgroundColor = UIColor.white
                post.imageView.layer.cornerRadius = 0
                post.imageView.image = defaultImage
            }
        }
    }
}
