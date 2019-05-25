//
//  Project.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

struct Project {
    var name: String
    var id: Int
    var finished: Date?
    var grade: Int
    var validated: Bool
    var retries: Int
    var piscineDays: [Project]?
}
