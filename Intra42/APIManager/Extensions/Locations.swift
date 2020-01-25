//
//  GetLocations.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    
    /**
    Gets all logged in user in specified campus.
        
    - Parameters:
        - id: ID of campus to check locations for
        - completionHandler: Called with array of online users' ID Strings.
    */
    func getOnlineUsers(forCampus id: Int, completionHandler: @escaping ([String]) -> Void) {
        var onlineUsers: [String] = []
        
        func getOnline(_ id: Int, _ page: Int) {
            let url = baseURL + "campus/\(id)/locations?filter[active]=true&page[number]=\(page)&page[size]=100"
            
            request(url: url) { (data) in
                guard let data = data?.arrayValue else {
                    completionHandler(onlineUsers)
                    return
                }
                onlineUsers.append(contentsOf: data.map { $0["user"]["id"].stringValue })
                if data.count == 100 {
                    getOnline(id, page + 1)
                } else {
                    completionHandler(onlineUsers)
                }
            }
        }
        
        getOnline(id, 1)
    }
    
    /**
     Gets all logged in users and their locations for specified campus.
     
     Recursive function getting all logged in users by incrementing the page
     parameter.
     
     - Parameters:
        - id: ID for campus to check locations for
        - page: Page number to start recursion. Should be 1 to get all users.
        - completionHandler: Called with array of received JSON data.
     */
    func getLocations(forCampusId id: Int, page: Int, completionHandler: @escaping ([JSON]) -> Void) {
        let locationURL = baseURL + "campus/\(id)/locations?filter[active]=true&page[number]=\(page)&page[size]=100"
        
        request(url: locationURL) { (data) in
            guard let data = data  else {
                completionHandler([])
                return
            }
            self.locationData += data.arrayValue
            if data.arrayValue.count == 100 {
                print("Location Page \(page)")
                self.getLocations(forCampusId: id, page: page + 1, completionHandler: completionHandler)
            } else {
                completionHandler(self.locationData)
                self.locationData = []
            }
        }
    }
    
    /**
     Gets all location logs (up to 100) for specified user.
     
     Parses the JSON data to retrieve each day and all of its locations
     with timestamps and durations.
     
     - Parameters:
     - userId: ID for user to check for logs
     - completionHandler: Called with array of `LocationLog`. Empty on error.
     */
    func getLogs(forUserId id: Int, completionHandler: @escaping ([LocationLog]) -> Void) {
        API42Manager.shared.request(url: baseURL + "locations?filter[user_id]=\(id)&page[size]=100") { (data) in
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
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
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
