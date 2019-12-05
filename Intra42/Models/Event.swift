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

enum EventKind: String {
    case event
    case exam
    case hackathon
    case association
    case conference
    case workshop
    case meetup
    case extern
}

struct Event: Equatable {
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
            color = (Colors.EventType.event, Colors.EventType.eventPale)
        case .exam:
            color = (Colors.EventType.exam, Colors.EventType.examPale)
        case .association:
            color = (Colors.EventType.association, Colors.EventType.associationPale)
        case .conference:
            color = (Colors.EventType.conference, Colors.EventType.conferencePale)
        case .extern:
            color = (Colors.EventType.extern, Colors.EventType.externPale)
        case .hackathon:
            color = (Colors.EventType.hackathon, Colors.EventType.hackathonPale)
        case .meetup:
            color = (Colors.EventType.meetup, Colors.EventType.meetupPale)
        case .workshop:
            color = (Colors.EventType.workshop, Colors.EventType.workshopPale)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
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
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
}
