//
//  ViewTriangle.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-16.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

@IBDesignable class Triangle: UIView {
    
    @IBInspectable var color: UIColor = .clear
    @IBInspectable var pointOneX: CGFloat = 0
    @IBInspectable var pointOneY: CGFloat = 0
    @IBInspectable var pointTwoX: CGFloat = 0.5
    @IBInspectable var pointTwoY: CGFloat = 1
    @IBInspectable var pointThreeX: CGFloat = 1
    @IBInspectable var pointThreeY: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        let aPath = UIBezierPath()
        aPath.move(to: CGPoint(x: self.pointOneX * rect.width, y: self.pointOneY * rect.height))
        aPath.addLine(to: CGPoint(x: self.pointTwoX * rect.width, y: self.pointTwoY * rect.height))
        aPath.addLine(to: CGPoint(x: self.pointThreeX * rect.width, y: self.pointThreeY * rect.height))
        aPath.close()

        self.color.set()
        self.backgroundColor = .white
        aPath.fill()
    }
}
