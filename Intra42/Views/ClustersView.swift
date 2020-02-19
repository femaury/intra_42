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
}

class ClustersView: UIView {
    var delegate: ClustersViewDelegate?
    var data: [ClusterData] = []
    
    init(withData data: [ClusterData]) {
        super.init(frame: CGRect(x: 0, y: 0, width: 400, height: 55))
        self.commonInit(data)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func commonInit(_ data: [ClusterData]) {
        
    }
    
    func setupCluster(withUsers users: [String: ClusterPerson]) {
        
    }
}
