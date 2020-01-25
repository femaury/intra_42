//
//  SelectableTableViewCell.swift
//  Intra42
//
//  Created by Felix Maury on 07/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

//class SelectableTableViewCell: UITableViewCell {
//
//    weak var delegate: PeerFinderViewController?
//    var indexPath: IndexPath?
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        self.addGestureRecognizer(tapGesture)
//        self.selectionStyle = .none
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    @objc func handleTap(_ sender: Any?) {
//        guard let indexPath = indexPath else { return }
//        let isSelected = self.accessoryType == .checkmark
//        self.accessoryType = isSelected ? .none : .checkmark
////        delegate?.selectedRowAt(indexPath: indexPath)
//    }
//}
