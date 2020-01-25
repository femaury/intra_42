//
//  ProjectsUsers.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-05.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

extension API42Manager {
    
    func getProjectUsers(forProjectId id: Int, campusId: Int, filter: PeerFinderViewController.Filter, completionHandler: @escaping ([ProjectUser], Bool) -> Bool) {
        var projectUsers: [ProjectUser] = []
        
        getOnlineUsers(forCampus: campusId) { (usersString) in
            var filterStr: String
            switch filter {
            case .validated:
                filterStr = "&filter[marked]=true"
            case .inProgress:
                filterStr = "&filter[marked]=false"
            case .all:
                filterStr = ""
            }
            
            func getUsers(page: Int, isOnlinePass: Bool) {
                var idFilterStr = ""
                if isOnlinePass && !usersString.isEmpty {
                    idFilterStr = "&filter[user_id]=\(usersString.joined(separator: ","))"
                }
                let url = self.baseURL
                    + "projects/\(id)/projects_users?filter[campus]=\(campusId)"
                    + "\(filterStr)\(idFilterStr)&page[size]=100&page[number]=\(page)"
                
                self.request(url: url) { (data) in
                    guard let rawData = data?.arrayValue else {
                        _ = completionHandler(projectUsers, true)
                        return
                    }
                    
                    let data = rawData.filter { !$0["user"]["login"].stringValue.contains("3b") }
                    let isLastLoop = (!isOnlinePass && rawData.count != 100) || projectUsers.count >= 300
                    let idString = data.map { $0["user"]["id"].stringValue } .joined(separator: ",")
                    let locationURL = API42Manager.shared.baseURL + "locations?filter[user_id]=\(idString)&filter[active]=true&page[size]=100"
                    self.request(url: locationURL) { (locationData) in
                        let res = data.compactMap { (projUser) -> ProjectUser? in
                            let user = projUser["user"]
                            let id = user["id"].intValue
                            if !isOnlinePass && usersString.contains(String(id)) {
                                return nil
                            }
                            var location = "Unavailable"
                            if let locationArray = locationData?.arrayValue {
                                location = locationArray.first { $0["user"]["id"].intValue == id }?["host"].stringValue ?? "Unavailable"
                            }
                            
                            return ProjectUser(
                                id: id,
                                login: user["login"].stringValue,
                                marked: projUser["marked"].boolValue,
                                status: projUser["status"].stringValue,
                                grade: projUser["final_mark"].intValue,
                                validated: projUser["validated?"].boolValue,
                                location: location)
                        }
                        
                        projectUsers.append(contentsOf: res)
                        if isLastLoop {
                            _ = completionHandler(projectUsers, true)
                        } else if !isLastLoop && completionHandler(projectUsers, false) {
                            getUsers(page: page + 1, isOnlinePass: false)
                        }
                    }
                    
                }
            }
            
            getUsers(page: 1, isOnlinePass: true)
        }
    }
    
    func getProjectUserId(forProjectId id: Int, userId: Int, completionHandler: @escaping (Int?) -> Void) {
        let url = baseURL + "users/\(userId)/projects_users?filter[project_id]=\(id)"
        
        request(url: url) { (eventUser) in
            guard let projectUser = eventUser?.array else {
                completionHandler(nil)
                return
            }
            let id = projectUser.first?["id"].int
            completionHandler(id)
        }
    }
    
    func modifyProject(withId id: Int, method: HTTPMethod, completionHandler: @escaping (Bool) -> Void) {
        guard let userId = userProfile?.userId else {
            completionHandler(false)
            return
        }
        switch method {
        case .post:
            let url = baseURL + "projects_users?projects_user[project_id]=\(id)&projects_user[user_id]=\(userId)"
            _modifyProject(url: url, method: method, completiondHandler: completionHandler)
        case .patch:
            getProjectUserId(forProjectId: id, userId: userId) { [weak self] (projectUserId) in
                guard let id = projectUserId, let self = self else {
                    completionHandler(false)
                    return
                }
                let url = self.baseURL + "projects_users/\(id)/retry"
                self._modifyProject(url: url, method: method, completiondHandler: completionHandler)
            }
        case .delete:
            getProjectUserId(forProjectId: id, userId: userId) { [weak self] (projectUserId) in
                guard let id = projectUserId, let self = self else {
                    completionHandler(false)
                    return
                }
                let url = self.baseURL + "projects_users/\(id)"
                self._modifyProject(url: url, method: method, completiondHandler: completionHandler)
            }
        default:
            completionHandler(false)
        }
    }
    
    private func _modifyProject(url: String, method: HTTPMethod, completiondHandler: @escaping (Bool) -> Void) {
        if hasOAuthToken(), let token = oAuthAccessToken, let url = URL(string: url) {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (_, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Request Error:", error)
                        completiondHandler(false)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Status code: \(httpResponse.statusCode)")
                        if httpResponse.statusCode == 201 || httpResponse.statusCode == 204 {
                            completiondHandler(true)
                            return
                        }
                    }
                    completiondHandler(false)
                }
            }.resume()
        }
    }
}
