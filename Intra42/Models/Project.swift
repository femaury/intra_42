//
//  Project.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

enum ProjectState: String {
    case success = "done"
    case fail = "fail"
    case inProgress = "in_progress"
    case available = "available"
    case unavailable = "unavailable"
}

struct ProjectInfo {
    var id: Int
    var name: String
    var exp: Int
    var groupSize: String
    var duration: String
    var state: ProjectState
    var grade: String
    var description: String
    var objectives: [String]
}

struct ProjectItem {
    var name: String
    var slug: String
    var id: Int
}

struct Project {
    var name: String
    var id: Int
    var finished: Date?
    var grade: Int
    var validated: Bool
    var retries: Int
    var piscineDays: [Project]?
}
