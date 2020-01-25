//
//  Campus.swift
//  Intra42
//
//  Created by Felix Maury on 14/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension API42Manager {
    func getAllCampus(refresh: Bool = false, completionHandler: @escaping ([(id: Int, name: String)]) -> Void) {
        var campus: [(id: Int, name: String)] = []
        
        func getCampus(page: Int) {
            let url = API42Manager.shared.baseURL + "campus?sort=name&page[size]=100&page[number]=\(page)"
            
            API42Manager.shared.request(url: url) { (data) in
                guard let data = data?.array else {
                    self._saveCampus(campus: campus)
                    completionHandler(campus)
                    return
                }
                let parsed = data.map { ($0["id"].intValue, $0["name"].stringValue) }
                campus.append(contentsOf: parsed)
                if data.count == 100 {
                    getCampus(page: page + 1)
                } else {
                    self._saveCampus(campus: campus)
                    completionHandler(campus)
                }
            }
        }
        
        if refresh {
            getCampus(page: 1)
        } else {
            let localCampus = _retrieveCampus()
            if localCampus.isEmpty {
                getCampus(page: 1)
            } else {
                completionHandler(localCampus)
            }
        }
    }
    
    // CoreData Helpers to save loading time by caching server data
    fileprivate func _retrieveCampus() -> [(id: Int, name: String)] {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return [] }

        let managedContext = app.coreData.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Campus")
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]

        do {
            let campus = try managedContext.fetch(fetchRequest)
            return campus.map { ($0.value(forKey: "id") as! Int, $0.value(forKey: "name") as! String) }
        } catch let error as NSError {
            print("Could not retrieve campus. \(error), \(error.userInfo)")
            return []
        }
    }

    fileprivate func _saveCampus(campus: [(id: Int, name: String)]) {
        guard let app = UIApplication.shared.delegate as? AppDelegate, !campus.isEmpty else { return }

        let managedContext = app.coreData.persistentContainer.viewContext
        managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        guard let entity = NSEntityDescription.entity(forEntityName: "Campus", in: managedContext) else { return }
        for cur in campus {
            let campusObj = NSManagedObject(entity: entity, insertInto: managedContext)
            campusObj.setValue(cur.name, forKeyPath: "name")
            campusObj.setValue(cur.id, forKey: "id")
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save new campus. \(error), \(error.userInfo)")
            return
        }
    }
}
