//
//  Cursus.swift
//  Intra42
//
//  Created by Felix Maury on 07/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension API42Manager {
    
    func getAllCursus(refresh: Bool = false, completionHandler: @escaping ([(id: Int, name: String)]) -> Void) {
        var cursus: [(id: Int, name: String)] = []
        
        func getCursus(page: Int) {
            let url = API42Manager.shared.baseURL + "cursus?sort=name&page[size]=100&page[number]=\(page)"
            
            API42Manager.shared.request(url: url) { (data) in
                guard let data = data?.array else {
                    self._saveCursus(cursus: cursus)
                    completionHandler(cursus)
                    return
                }
                let parsed = data.map { ($0["id"].intValue, $0["name"].stringValue) }
                cursus.append(contentsOf: parsed)
                if data.count == 100 {
                    getCursus(page: page + 1)
                } else {
                    self._saveCursus(cursus: cursus)
                    completionHandler(cursus)
                }
            }
        }
        
        if refresh {
            getCursus(page: 1)
        } else {
            let localCursus = _retrieveCursus()
            if localCursus.isEmpty {
                getCursus(page: 1)
            } else {
                completionHandler(localCursus)
            }
        }
    }
}

// CoreData Helpers to save loading time by caching server data
extension API42Manager {
       fileprivate func _retrieveCursus() -> [(id: Int, name: String)] {
           guard let app = UIApplication.shared.delegate as? AppDelegate else { return [] }

           let managedContext = app.coreData.persistentContainer.viewContext
           let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cursus")
           let sort = NSSortDescriptor(key: "name", ascending: true)
           fetchRequest.sortDescriptors = [sort]

           do {
               let cursus = try managedContext.fetch(fetchRequest)
               return cursus.map { ($0.value(forKey: "id") as! Int, $0.value(forKey: "name") as! String) }
           } catch let error as NSError {
               print("Could not retrieve cursus. \(error), \(error.userInfo)")
               return []
           }
       }

       fileprivate func _saveCursus(cursus: [(id: Int, name: String)]) {
           guard let app = UIApplication.shared.delegate as? AppDelegate, !cursus.isEmpty else { return }

           let managedContext = app.coreData.persistentContainer.viewContext
           managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
           guard let entity = NSEntityDescription.entity(forEntityName: "Cursus", in: managedContext) else { return }
           for cur in cursus {
               let cursusObj = NSManagedObject(entity: entity, insertInto: managedContext)
               cursusObj.setValue(cur.name, forKeyPath: "name")
               cursusObj.setValue(cur.id, forKey: "id")
           }

           do {
               try managedContext.save()
           } catch let error as NSError {
               print("Could not save new cursus. \(error), \(error.userInfo)")
               return
           }
       }
}
