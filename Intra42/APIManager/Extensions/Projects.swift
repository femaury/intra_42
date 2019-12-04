//
//  Projects.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-03.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {

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
            var info = ProjectInfo(
                id: id,
                name: name,
                exp: exp,
                groupSize: "Fuck this API",
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
