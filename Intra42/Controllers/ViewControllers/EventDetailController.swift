//
//  EventDetailController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-11.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import EventKit

class EventDetailController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var topColorView: UIStackView!
    @IBOutlet weak var bottomColorView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var addToCalendarButton: UIBarButtonItem!
    
    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMMM d, YYYY 'at' HH:mm"
        
        let view = UIView()
        view.backgroundColor = event.color.pale
        view.translatesAutoresizingMaskIntoConstraints = false
        topColorView.insertSubview(view, at: 0)
        view.pin(to: topColorView)

        navigationItem.title = event.kind.rawValue.capitalized
        nameLabel.text = event.name
        dateLabel.text = dateFormatter.string(from: event.begin)
        
        bottomColorView.backgroundColor = event.color.reg
        durationLabel.text = event.duration
        locationLabel.text = event.location
        capacityLabel.text = "\(event.currentUsers)/\(event.maxUsers)"
        
        descriptionText.text = event.description
        descriptionText.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    @IBAction func syncCalendar(_ sender: UIBarButtonItem) {
        let syncCalendarAction = UIAlertController(title: "Add this event to your default calendar",
                                                   message: "You will be notified 24 hours prior",
                                                   preferredStyle: .actionSheet)
        let syncAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { (granted, error) in
                
                if (granted) && (error == nil) {
                    let newEvent = EKEvent(eventStore: eventStore)
                    
                    newEvent.title = self.event.name
                    newEvent.startDate = self.event.begin
                    newEvent.endDate = self.event.end
                    newEvent.notes = "\(self.event.kind.rawValue.capitalized) event at 42"
                    newEvent.structuredLocation = EKStructuredLocation(title: self.event.location)
                    newEvent.calendar = eventStore.defaultCalendarForNewEvents
                    let dayBeforeAlarm = EKAlarm(relativeOffset: -3600 * 24)
                    newEvent.addAlarm(dayBeforeAlarm)
                    do {
                        try eventStore.save(newEvent, span: .thisEvent)
                        self.addToCalendarButton.isEnabled = false
                    } catch let error as NSError {
                        print("Failed to save event: \(error)")
                    }
                } else {
                    if let err = error {
                        print("Error: \(err)")
                    } else {
                        print("Error: Event store access not granted")
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        syncCalendarAction.addAction(syncAction)
        syncCalendarAction.addAction(cancelAction)
        present(syncCalendarAction, animated: true)
    }
}
