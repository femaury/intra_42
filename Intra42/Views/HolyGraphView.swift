//
//  HolyGraphView.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class HolyGraphView: UIView {
    
    let label = UILabel()
    let borderView = UIView()
    
    var kind: String = ""
    var state: String = ""
    var cornerRadius: CGFloat {
        return kind == "piscine" ? 0 : self.frame.width / 2
    }
    
    init(kind: String, state: String, position: CGPoint, title: String) {
        super.init(frame: .zero)
        self.kind = kind
        self.state = state
        
        frame = CGRect(origin: position, size: getViewSize())
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        backgroundColor = getBackgroundColor()

        borderView.layer.borderWidth = 5
        borderView.layer.cornerRadius = cornerRadius
        borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        borderView.frame = bounds
        borderView.layer.borderColor = getBorderColor()
        
        label.numberOfLines = 0
        label.text = title
        label.font = label.font.withSize(14)
        label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        
        if kind == "first_internship" || kind == "second_internship" {
            clipsToBounds = false
            backgroundColor = .clear
            borderView.layer.borderWidth = 10
            label.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            label.center = CGPoint(x: bounds.maxX - bounds.maxX / 6.8, y: bounds.maxY - bounds.maxY / 6.8)
            label.layer.cornerRadius = 100
            label.layer.borderColor = getBorderColor()
            label.layer.borderWidth = 10
            label.backgroundColor = getBackgroundColor()
            label.layer.masksToBounds = true
        } else {
            label.center = convert(center, from: label)
        }
        
        addSubview(borderView)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func getViewSize() -> CGSize {
        switch kind {
        case "piscine":
            return CGSize(width: 170, height: 40)
        case "big_project":
            return CGSize(width: 105, height: 105)
        case "project":
            return CGSize(width: 95, height: 95)
        case "first_internship":
            return CGSize(width: 2000, height: 2000)
        case "second_internship":
            return CGSize(width: 4500, height: 4500)
        case "part_time":
            return CGSize(width: 300, height: 300)
        default:
            return CGSize(width: 120, height: 120)
        }
    }

    func getBorderColor() -> CGColor? {
        switch state {
        case "done":
            return Colors.intraTeal?.cgColor
        case "in_progress":
            return Colors.intraTeal?.cgColor
        case "available":
            return UIColor.white.cgColor
        default:
            return UIColor.darkGray.cgColor
        }
    }
    
    func getBackgroundColor() -> UIColor? {
        return state == "done" ? Colors.intraTeal : .darkGray
    }
}
