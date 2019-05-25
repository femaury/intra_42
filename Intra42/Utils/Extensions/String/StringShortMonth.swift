//
//  StringShortMonth.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-07.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

extension String {
    func getPiscineShortMonth() -> String? {
        switch self {
        case "january", "January":
            return "Jan."
        case "february", "February":
            return "Feb."
        case "march", "March":
            return "March"
        case "april", "April":
            return "April"
        case "may", "May":
            return "May"
        case "june", "June":
            return "June"
        case "july", "July":
            return "July"
        case "august", "August":
            return "Aug."
        case "september", "September":
            return "Sept."
        case "october", "October":
            return "Oct."
        case "november", "November":
            return "Nov."
        case "december", "December":
            return "Dec."
        default :
            return nil
        }
    }
}
