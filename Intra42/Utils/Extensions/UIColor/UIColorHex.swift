//
//  UIColorHex.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-28.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name
extension UIColor {
    convenience init?(hexRGBA: String?) {
        guard
            let rgba = hexRGBA,
            let val = Int(rgba.replacingOccurrences(of: "#", with: ""), radix: 16)
        else { return nil }

        let r = CGFloat((val >> 24) & 0xff) / 255.0
        let g = CGFloat((val >> 16) & 0xff) / 255.0
        let b = CGFloat((val >> 8) & 0xFF) / 255.0
        let a = CGFloat(val & 0xff) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    convenience init?(hexRGB: String?) {
        guard let rgb = hexRGB else { return nil }
        self.init(hexRGBA: rgb + "ff")
    }
    
    var toHex: String? {
        return toHex()
    }
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

}
// swiftlint:enable identifier_name
