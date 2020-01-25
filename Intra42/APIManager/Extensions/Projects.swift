//
//  Projects.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-03.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension API42Manager {
    
    func getAllProjects(forCursus id: Int, refresh: Bool = false, completionHandler: @escaping ([ProjectItem]) -> Void) {
        var projects: [ProjectItem] = []
        
        func getProjects(page: Int) {
            let url = API42Manager.shared.baseURL + "cursus/\(id)/projects?filter[exam]=false&sort=name&page[size]=100&page[number]=\(page)"
            
            API42Manager.shared.request(url: url) { (data) in
                guard let data = data?.array else {
                    self._saveProjects(projects: projects, cursusId: id)
                    completionHandler(projects)
                    return
                }
                print("PROJECTS \(data.count)")
                let parsed = data.map { ProjectItem(name: $0["name"].stringValue, slug: $0["slug"].stringValue, id: $0["id"].intValue) }
                projects.append(contentsOf: parsed)
                if data.count == 100 {
                    getProjects(page: page + 1)
                } else {
                    self._saveProjects(projects: projects, cursusId: id)
                    completionHandler(projects)
                }
            }
        }
        if refresh {
            getProjects(page: 1)
        } else {
            let projects = _retrieveProjects(cursusId: id)
            if projects.isEmpty {
                getProjects(page: 1)
            } else {
                completionHandler(projects)
            }
        }
    }

    func getProjectInfo(withId id: Int, forUser userId: Int, campusId: Int, completionHandler: @escaping (ProjectInfo?) -> Void) {
        let url = API42Manager.shared.baseURL + "projects/\(id)"

        request(url: url) { (data) in
            guard let data = data else {
                completionHandler(nil)
                return
            }
            print(data)
            let name = data["name"].stringValue
            let sessions = data["project_sessions"].arrayValue
            guard sessions.count > 0 else {
                completionHandler(nil)
                return
            }
            var session: JSON = sessions[0]
            for sesh in sessions where sesh["campus_id"].intValue == campusId {
                session = sesh
            }
            let description = session["description"].stringValue
            print("DESCRIPTION: \(description)")
            let exp = session["difficulty"].intValue
            let objectives = session["objectives"].arrayValue.map { $0.stringValue}
            let group = session["solo"].boolValue ? "Solo" : "In a group"
            var info = ProjectInfo(
                id: id,
                name: name,
                exp: exp,
                groupSize: group,
                duration: "",
                state: .unavailable,
                grade: "",
                description: description,
                objectives: objectives)
            let userUrl = API42Manager.shared.baseURL + "projects/\(id)/projects_users?filter[user_id]=\(userId)"
            self.request(url: userUrl) { (data) in
                guard let data = data, data.count > 0 else {
                    completionHandler(info)
                    return
                }
                print(data)
                var mark = 0
                for team in data.arrayValue {
                    let grade = team["final_mark"].intValue
                    if grade > mark {
                        mark = grade
                    }
                }
                let grade = "\(mark)/100"
                info.grade = grade
                completionHandler(info)
            }
        }
    }
    
    func getProject(withId id: Int, completionHandler: @escaping (JSON?) -> Void) {
        let projectURL = baseURL + "projects/\(id)"
        
        request(url: projectURL) { (data) in
            completionHandler(data)
        }
    }
}

// CoreData Helpers to save loading time by caching server data
extension API42Manager {
    fileprivate func _retrieveProjects(cursusId id: Int) -> [ProjectItem] {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let managedContext = app.coreData.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Projects")
        fetchRequest.predicate = NSPredicate(format: "cursusId == %@", NSNumber(value: id))
        let sort = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let projects = try managedContext.fetch(fetchRequest)
            return projects.map { ProjectItem(name: $0.value(forKey: "name") as! String,
                                              slug: $0.value(forKey: "slug") as! String,
                                              id: $0.value(forKey: "id") as! Int) }
        } catch let error as NSError {
            print("Could not retrieve projects. \(error), \(error.userInfo)")
            return []
        }
    }
    
    fileprivate func _saveProjects(projects: [ProjectItem], cursusId id: Int) {
        guard let app = UIApplication.shared.delegate as? AppDelegate, !projects.isEmpty else { return }
        
        let managedContext = app.coreData.persistentContainer.viewContext
        managedContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        guard let entity = NSEntityDescription.entity(forEntityName: "Projects", in: managedContext) else { return }
        for project in projects {
            let projectObj = NSManagedObject(entity: entity, insertInto: managedContext)
            projectObj.setValue(project.name, forKeyPath: "name")
            projectObj.setValue(project.id, forKey: "id")
            projectObj.setValue(project.slug, forKey: "slug")
            projectObj.setValue(id, forKey: "cursusId")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save new projects. \(error), \(error.userInfo)")
            return
        }
    }
}
