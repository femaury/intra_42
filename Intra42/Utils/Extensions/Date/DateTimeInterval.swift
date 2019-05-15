//
//  DateTimeInterval.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-03.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

extension Date {
    
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year) year ago" : "\(year) years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month) month ago" : "\(month) months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day) day ago" : "\(day) days ago"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour) hour ago" : "\(hour) hours ago"
        } else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "\(minute) minute ago" : "\(minute) minutes ago"
        } else {
            return "Less than a minute ago"
        }
    }
    
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        let y = years(from: date)
        if y > 0 {
            return y == 1 ? "In \(years(from: date)) year" : "In \(years(from: date)) years"
        }
        
        let m = months(from: date)
        if m > 0 {
            return m == 1 ? "In \(months(from: date)) month" : "In \(months(from: date)) months"
        }
        
        let w = weeks(from: date)
        if w > 0 {
            return w == 1 ? "In \(weeks(from: date)) week" : "In \(weeks(from: date)) weeks"
        }
        
        let d = days(from: date)
        if d > 0 {
            return d == 1 ? "In \(days(from: date)) day" : "In \(days(from: date)) days"
        }
        
        let h = hours(from: date)
        if h > 0 {
            return h == 1 ? "In \(hours(from: date)) hour" : "In \(hours(from: date)) hours"
        }

        let min = minutes(from: date)
        if min > 0 {
            return min == 1 ? "In \(minutes(from: date)) minute" : "In \(minutes(from: date)) minutes"
        }
        
        let sec = seconds(from: date)
        if sec > 0 {
            return sec == 1 ? "In \(seconds(from: date)) second" : "In \(seconds(from: date)) seconds"
        }
        
        return getElapsedInterval()
    }
}
