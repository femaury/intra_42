//
//  UIImageViewRoundFrame.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-22.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

extension UIImageView {
    public func roundFrame() {
        layer.masksToBounds = false
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
}
