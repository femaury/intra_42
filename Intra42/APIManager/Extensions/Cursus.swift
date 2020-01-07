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
            let url = API42Manager.shared.baseURL + "cursus?page[size]=100&page[number]=\(page)"
            
            API42Manager.shared.request(url: url) { (data) in
                guard let data = data?.array else {
                    self._saveCursus(cursus: cursus)
                    completionHandler(cursus.sorted { $0.id < $1.id })
                    return
                }
                let parsed = data.map { ($0["id"].intValue, $0["slug"].stringValue) }
                cursus.append(contentsOf: parsed)
                if cursus.count == 100 {
                    getCursus(page: page + 1)
                } else {
                    self._saveCursus(cursus: cursus)
                    completionHandler(cursus.sorted { $0.id < $1.id })
                }
            }
        }
        if refresh {
            getCursus(page: 0)
        } else {
            let cursus = _retrieveCursus()
            if cursus.isEmpty {
                getCursus(page: 0)
            } else {
                completionHandler(cursus.sorted { $0.id < $1.id })
            }
        }
    }
    
    fileprivate func _retrieveCursus() -> [(id: Int, name: String)] {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let managedContext = app.coreData.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cursus")
        
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
