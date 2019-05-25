//
//  GetLogs.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    func getLogsForUser(withId id: Int, completionHandler: @escaping ([LocationLog]) -> Void) {
        API42Manager.shared.request(url: "https://api.intra.42.fr/v2/locations?filter[user_id]=\(id)&page[size]=100") { (data) in
            guard let logs = data?.arrayValue else {
                completionHandler([])
                return
            }
            
            var previousDay = ""
            var locationLogs: [LocationLog] = []
            for log in logs {
                let location = log["host"].stringValue
                let dateString = log["begin_at"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                if let dateUTC = dateFormatter.date(from: dateString) {
                    let endDateUTC = dateFormatter.date(from: log["end_at"].stringValue) ?? Date()
                    dateFormatter.dateFormat = "MMMM d, yyyy"
                    dateFormatter.timeZone = TimeZone.current
                    let day = dateFormatter.string(from: dateUTC)
                    
                    dateFormatter.dateFormat = "HH:mm"
                    let beginHour = dateFormatter.string(from: dateUTC)
                    let hours = Int(endDateUTC.timeIntervalSince(dateUTC)) / 3600
                    let minutes = (Int(endDateUTC.timeIntervalSince(dateUTC)) / 60) % 60
                    var timeInterval: String
                    if hours == 0 {
                        timeInterval = "\(minutes) minute"
                        if minutes != 1 {
                            timeInterval += "s"
                        }
                    } else {
                        timeInterval = "\(hours) hour"
                        if hours != 1 {
                            timeInterval += "s"
                        }
                    }
                    var endHour: String
                    if log["end_at"] == JSON.null {
                        endHour = "now"
                    } else {
                        endHour = dateFormatter.string(from: endDateUTC)
                    }
                    
                    let calendar = Calendar.current
                    let dayOne = calendar.startOfDay(for: dateUTC)
                    let dayTwo = calendar.startOfDay(for: endDateUTC)
                    
                    if let daysDiff = Calendar.current.dateComponents([.day], from: dayOne, to: dayTwo).day {
                        if daysDiff > 0 {
                            endHour += " (+\(daysDiff))"
                        }
                    }
                    let timeString = "From \(beginHour) to \(endHour) for \(timeInterval)"
                    
                    if day == previousDay {
                        locationLogs.last?.logs.append((location, timeString))
                    } else {
                        previousDay = day
                        locationLogs.append(LocationLog(day: day, logs: [(location, timeString)]))
                    }
                }
                completionHandler(locationLogs)
            }
        }
    }
}
