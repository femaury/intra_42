//
//  Corrections.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

struct Correction {
    let name: String
    let team: (id: Int, name: String)
    let projectId: Int
    let repoURL: String
    let isCorrector: Bool
    let corrector: User
    let correctees: [User]
    let startDate: Date
}
