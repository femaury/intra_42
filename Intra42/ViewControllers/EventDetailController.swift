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
    
    var event: Event?
    weak var delegate: EventsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keeps navbar background color black in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMMM d, YYYY 'at' HH:mm"

        if let event = event {
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func notifySubscription(with message: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotificationView") as! NotificationViewController
        _ = controller.view // Force controller to load outlets
        controller.messageLabel.text = message
        controller.imageView.image = controller.imageView.image?.withRenderingMode(.alwaysTemplate)
        controller.providesPresentationContextTransitionStyle = true
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func syncCalendar(_ sender: UIBarButtonItem) {
        guard let myEvents = delegate?.myEvents, let event = event else { return }
        
        let calendarAction = UIAlertController(title: event.name, message: nil, preferredStyle: .actionSheet)
        let subAction = UIAlertAction(title: "Subscribe", style: .default) { [weak self] (_) in
            guard let id = self?.event?.id else { return }
            API42Manager.shared.modifyEvent(withId: id, method: .post) { [weak self] success in
                if success, let event = self?.event {
                    guard let delegate = self?.delegate else { return }
                    
                    delegate.myEvents.append(event)
                    self?.notifySubscription(with: "Subscribed!")
                } else {
                    API42Manager.shared.showErrorAlert(message: "There was an error subscribing to the event...")
                }
            }
        }
        
        let unsubAction = UIAlertAction(title: "Unsubscribe", style: .destructive) { [weak self] (_) in
            guard let id = self?.event?.id else { return }
            API42Manager.shared.modifyEvent(withId: id, method: .delete) { [weak self] success in
                if success, let event = self?.event {
                    guard let delegate = self?.delegate else { return }

                    if let index = delegate.myEvents.firstIndex(of: event) {
                        delegate.myEvents.remove(at: index)
                    }
                    self?.notifySubscription(with: "Unsubscribed.")
                } else {
                    API42Manager.shared.showErrorAlert(message: "There was an error unsubscribing from the event...")
                }
            }
        }
        
        let syncAction = UIAlertAction(title: "Add to calendar", style: .default) { [weak self] (_) in
            func presentAlert(title: String, message: String, preferredStyle style: UIAlertController.Style) {
                let alert = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: style
                )
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { (granted, error) in
                
                if (granted) && (error == nil) {
                    let newEvent = EKEvent(eventStore: eventStore)
                    
                    newEvent.title = event.name
                    newEvent.startDate = event.begin
                    newEvent.endDate = event.end
                    newEvent.notes = "\(event.kind.rawValue.capitalized) event at 42"
                    newEvent.structuredLocation = EKStructuredLocation(title: event.location)
                    newEvent.calendar = eventStore.defaultCalendarForNewEvents
                    let dayBeforeAlarm = EKAlarm(relativeOffset: -3600 * 24)
                    newEvent.addAlarm(dayBeforeAlarm)
                    
                    let predicate = eventStore.predicateForEvents(withStart: event.begin, end: event.end, calendars: nil)
                    let existingEvents = eventStore.events(matching: predicate)

                    let eventAlreadyExists = existingEvents.contains {
                        $0.title == event.name && $0.startDate == event.begin && $0.endDate == event.end
                    }

                    if eventAlreadyExists {
                        presentAlert(
                            title: "Event Already Exists",
                            message: "You have already saved this event!",
                            preferredStyle: .alert
                        )
                    } else {
                        do {
                            try eventStore.save(newEvent, span: .thisEvent)
                            DispatchQueue.main.async {
                                self?.notifySubscription(with: "Added!")
                            }
                        } catch let error as NSError {
                            print("Failed to save event: \(error)")
                            presentAlert(
                                title: "Failed to saved event.",
                                message: "There was an error saving this event to your calendar...",
                                preferredStyle: .alert
                            )
                        }
                    }
                } else {
                    if let err = error {
                        print("Error: \(err)")
                    } else {
                        print("Error: Event store access not granted")
                    }
                    presentAlert(
                        title: "Failed to access Calendar.",
                        message: "You need to give Intra 42 access to your calendar to save events",
                        preferredStyle: .alert
                    )
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        if myEvents.contains(event) {
            calendarAction.addAction(unsubAction)
        } else {
            calendarAction.addAction(subAction)
        }
        
        calendarAction.addAction(syncAction)
        calendarAction.addAction(cancelAction)
        present(calendarAction, animated: true)
    }
}
