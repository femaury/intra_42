//
//  ProjectTeam.swift
//  Intra42
//
//  Created by Felix Maury on 2019-06-10.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

struct Evaluation {
    let corrector: User
    let timeAgo: String
    let grade: Int
    let isValidated: Bool
    let comment: String
    let feedback: String
}

struct ProjectTeam {
    let id: Int
    let name: String
    let finalGrade: Int
    let isValidated: Bool
    let status: String
    let closedAt: String?
    let lockedAt: String?
    let repoURL: String
    let users: [User]
    let evaluations: [Evaluation]
}
