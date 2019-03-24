//
//  UIViewPinBackground.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-11.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}
