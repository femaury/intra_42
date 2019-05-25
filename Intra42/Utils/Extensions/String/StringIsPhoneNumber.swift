//
//  StringIsPhoneNumber.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-08.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            // swiftlint:disable legacy_constructor
            if let res = detector.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) {
                // swiftlint:enable legacy_constructor
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
