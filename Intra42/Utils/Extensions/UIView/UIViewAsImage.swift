//
//  UIViewAsImage.swift
//  Intra42
//
//  Created by Felix Maury on 26/03/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

extension UIView {
    func asImage() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    
    // Much faster but makes unselected tab bar icons white... ?? :(
    func takeScreenShot() -> UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot!
    }
}
