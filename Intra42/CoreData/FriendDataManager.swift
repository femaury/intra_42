//
//  DataManager.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-06.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import CoreData
import UIKit

class FriendDataManager {
    
    static let shared = FriendDataManager()
    
    let coreData = CoreDataManager()
    
    var friends: [Friend] = []
    
    init() {
        fetchFriends()
    }
    
    func notifyUser(withMessage message: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var topViewController = appDelegate.window?.rootViewController
        
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotificationView") as! NotificationViewController
        _ = controller.view // Force controller to load outlets
        controller.messageLabel.text = message
        controller.imageView.image = controller.imageView.image?.withRenderingMode(.alwaysTemplate)
        controller.providesPresentationContextTransitionStyle = true
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        topViewController?.present(controller, animated: true, completion: nil)
    }
    
    func saveNewFriend(_ newFriend: Friend) {
        guard hasFriend(withId: newFriend.id) == false else { return }
        
        let managedContext = coreData.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Friends", in: managedContext)!
        let friend = NSManagedObject(entity: entity, insertInto: managedContext)
        friend.setValue(newFriend.username, forKeyPath: "username")
        friend.setValue(newFriend.id, forKey: "id")
        friend.setValue(newFriend.phone, forKey: "phone")
        friend.setValue(newFriend.email, forKey: "email")
        
        do {
            try managedContext.save()
            friends.append(newFriend)
            notifyUser(withMessage: "Added friend!")
        } catch let error as NSError {
            print("Could not save new friend. \(error), \(error.userInfo)")
            return
        }
    }
    
    func fetchFriends() {
        let managedContext = coreData.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Friends")
        
        var requestResult: [NSManagedObject] = []
        
        do {
            requestResult = try managedContext.fetch(fetchRequest)
            
            for item in requestResult {
                let id = item.value(forKey: "id") as! Int
                let username = item.value(forKey: "username") as! String
                let phone = item.value(forKey: "phone") as! String
                let email = item.value(forKey: "email") as! String
                
                let friend = Friend(id: id, username: username, phone: phone, email: email)
                friends.append(friend)
            }
        } catch let error as NSError {
            print("Could not fetch friends. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFriend(withId id: Int) {
        let managedContext = coreData.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Friends")
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
        
        do {
            let requestResult = try managedContext.fetch(fetchRequest)
            if requestResult.count == 1 {
                managedContext.delete(requestResult[0])
                do {
                    try managedContext.save()
                    self.friends.remove(at: self.friends.firstIndex(where: {$0.id == id})!)
                    notifyUser(withMessage: "Removed friend.")
                } catch let error as NSError {
                    print("Could not save after deleting friend. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch friend to delete. \(error), \(error.userInfo)")
            return
        }
    }
    
    func hasFriend(withId id: Int) -> Bool {
        for friend in friends where friend.id == id {
            return true
        }
        return false
    }
}
