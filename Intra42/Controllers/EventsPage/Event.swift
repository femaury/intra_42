//
//  Event.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-09.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

let EventColor = UIColor(hexRGB: "#01BABC")
let EventColorPale = UIColor(hexRGB: "#77BBBC")

let ExamColor = UIColor(hexRGB: "#ED8179")
let ExamColorPale = UIColor(hexRGB: "#ED9E99")

let HackathonColor = UIColor(hexRGB: "#19B76F")
let HackathonColorPale = UIColor(hexRGB: "#48B785")

let AssociationColor = UIColor(hexRGB: "#6A85D5")
let AssociationColorPale = UIColor(hexRGB: "#8C9FD5")

let ConferenceColor = UIColor(hexRGB: "#3583B4")
let ConferenceColorPale = UIColor(hexRGB: "#6194B4")

let WorkshopColor = UIColor(hexRGB: "#87B021")
let WorkshopColorPale = UIColor(hexRGB: "#96B055")

let MeetupColor = UIColor(hexRGB: "#F64060")
let MeetupColorPale = UIColor(hexRGB: "F6788F")

let ExternColor = UIColor(hexRGB: "#6B6B6B")
let ExternColorPale = UIColor(hexRGB: "#979797")

enum EventKind: String {
    case event = "event"
    case exam = "exam"
    case hackathon = "hackathon"
    case association = "association"
    case conference = "conference"
    case workshop = "workshop"
    case meetup = "meetup"
    case extern = "extern"
}

struct Event {
    var id: Int
    var name: String
    var description: String
    var kind: EventKind
    var color: (reg: UIColor?, pale: UIColor?)
    var begin: Date
    var end: Date
    var duration: String
    var location: String
    var maxUsers: Int
    var currentUsers: Int
    
    init(event: JSON) {
        
        id = event["id"].intValue
        name = event["name"].stringValue
        description = event["description"].stringValue
        location = event["location"].stringValue
        maxUsers = event["max_people"].intValue
        currentUsers = event["nbr_subscribers"].intValue
        
        kind = EventKind(rawValue: event["kind"].stringValue) ?? .event
        switch kind {
        case .event:
            color = (EventColor, EventColorPale)
        case .exam:
            color = (ExamColor, ExamColorPale)
        case .association:
            color = (AssociationColor, AssociationColorPale)
        case .conference:
            color = (ConferenceColor, ConferenceColorPale)
        case .extern:
            color = (ExternColor, ExternColorPale)
        case .hackathon:
            color = (HackathonColor, HackathonColorPale)
        case .meetup:
            color = (MeetupColor, MeetupColorPale)
        case .workshop:
            color = (WorkshopColor, WorkshopColorPale)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let beginDate = dateFormatter.date(from: event["begin_at"].stringValue) {
            begin = beginDate
        } else {
            begin = Date()
        }
        if let endDate = dateFormatter.date(from: event["end_at"].stringValue) {
            end = endDate
        } else {
            end = Date()
        }
        
        dateFormatter.dateFormat = "HH:mm"
        let startHour = dateFormatter.string(from: begin)
        let timeDurationHours = end.timeIntervalSince(begin) / 3600
        var timeDurationDays = 0
        var timeDuration = "At \(startHour) for"
        if timeDurationHours > 23 {
            timeDurationDays = Int(timeDurationHours.truncatingRemainder(dividingBy: 24))
            timeDuration += " \(timeDurationDays) day"
            if timeDurationDays > 1 {
                timeDuration += "s"
            }
        } else {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            
            if timeDurationHours == 1.0 {
                timeDuration += " 1 hour"
            } else {
                let hours = NSNumber(value: timeDurationHours)
                timeDuration += " \(formatter.string(from: hours) ?? "0") hours"
            }
        }
        duration = timeDuration
    }
}
