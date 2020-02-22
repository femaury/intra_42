//
//  ClusterPost.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-13.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ClusterPost: UIView, UserProfileCell {

    static let NoPostTag: Int = 999
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    
    let textLabel = UILabel()
    
    weak var delegate: ClustersViewDelegate?
    var userId: Int = 0
    var userName: String?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 35, height: 55))
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ClusterPost", owner: self, options: nil)
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .width,
                           multiplier: 1.0,
                           constant: 35).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .height,
                           multiplier: 1.0,
                           constant: 55).isActive = true
        contentView.fixInView(self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showUser))
        addGestureRecognizer(tapGesture)
        
        textLabel.frame = frame
        textLabel.isHidden = true
        textLabel.textAlignment = .center
        addSubview(textLabel)
    }

    @objc func showUser(_ sender: UIGestureRecognizer) {
        guard let name = userName else { return }
        
        let showUserAction = UIAlertController(title: name, message: nil, preferredStyle: .actionSheet)
        let showProfile = UIAlertAction(title: "Show Profile", style: .default) { [weak self] (_) in
            self?.delegate?.selectedCell = self
            self?.delegate?.performSegue(withIdentifier: "UserProfileSegue", sender: self?.delegate)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        showUserAction.addAction(showProfile)
        showUserAction.addAction(cancel)
        
        delegate?.present(showUserAction, animated: true, completion: nil)
    }
    
    func setAsEmpty() {
        imageView.isHidden = true
        textLabel.isHidden = true
        numberLabel.isHidden = true
    }
    
    func setAsUser(withPos pos: String?) {
        textLabel.isHidden = true
        numberLabel.isHidden = false
        numberLabel.text = pos
        imageView.backgroundColor = nil
        imageView.image = UIImage(named: "monitor")
    }
    
    func setAsLabel(withText text: String?) {
        textLabel.text = text
        textLabel.isHidden = false
    }
    
    func setAsWall() {
        textLabel.isHidden = true
        numberLabel.isHidden = true
        if #available(iOS 13.0, *) {
            imageView.backgroundColor = .label
        } else {
            imageView.backgroundColor = .black
        }
        imageView.image = nil
    }
}
