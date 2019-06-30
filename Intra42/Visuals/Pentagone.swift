//
//  Pentagone.swift
//  Intra42
//
//  Created by Felix Maury on 2019-06-30.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

@IBDesignable class Pentagone: UIView {
    
    @IBInspectable var color: UIColor = .clear
    
    override func draw(_ rect: CGRect) {
        let size = self.bounds.size
        let height = size.height * 0.75      // adjust the multiplier to taste
        
        // calculate the 5 points of the pentagon
        let point1 = self.bounds.origin
        let point2 = CGPoint(x: point1.x + size.width, y: point1.y)
        let point3 = CGPoint(x: point2.x, y: point2.y + height)
        let point4 = CGPoint(x: size.width/2, y: size.height)
        let point5 = CGPoint(x: point1.x, y: height)
        
        // create the path
        let path = UIBezierPath()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addLine(to: point4)
        path.addLine(to: point5)
        path.close()
        
        // fill the path
        self.color.set()
        path.fill()
    }
}
