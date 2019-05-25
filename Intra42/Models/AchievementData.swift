//
//  AchievementData.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit


enum AchievementTier: String {
    case none = "none"
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    case challenge = "challenge"
    
    var color: UIColor? {
        switch self {
        case .none:
            return Colors.Achievement.none
        case .easy:
            return Colors.Achievement.bronze
        case .medium:
            return Colors.Achievement.silver
        case .hard:
            return Colors.Achievement.gold
        case .challenge:
            return Colors.Achievement.platinum
        }
    }
}

enum AchievementKind: String {
    case project = "project"
    case pedagogy = "pedagogy"
    case social = "social"
    case scolarity = "scolarity"
}
