//
//  UIColorHex.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-28.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

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
}
