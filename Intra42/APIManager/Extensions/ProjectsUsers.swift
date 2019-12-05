//
//  ProjectsUsers.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-05.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

extension API42Manager {
    
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
        if hasOAuthToken(), let token = OAuthAccessToken, let url = URL(string: url) {
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
