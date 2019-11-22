//
//  EventsUsers.swift
//  Intra42
//
//  Created by Felix Maury on 2019-08-20.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

extension API42Manager {
    
    func getEventUserId(forEventId id: Int, userId: Int, completionHandler: @escaping (Int?) -> Void) {
        let url = baseURL + "users/\(userId)/events_users?filter[event_id]=\(id)"
        
        request(url: url) { (eventUser) in
            guard let eventUser = eventUser?.array else {
                completionHandler(nil)
                return
            }
            let id = eventUser.first?["id"].int
            completionHandler(id)
        }
    }
    
    func modifyEvent(withId id: Int, method: HTTPMethod, completionHandler: @escaping (Bool) -> Void) {
        guard let userId = userProfile?.userId else {
            completionHandler(false)
            return
        }
        switch method {
        case .post:
            let url = baseURL + "events_users?events_user[event_id]=\(id)&events_user[user_id]=\(userId)"
            _modifyEvent(url: url, method: method, completiondHandler: completionHandler)
        case .delete:
            getEventUserId(forEventId: id, userId: userId) { [weak self] (eventUserId) in
                guard let eventUserId = eventUserId, let self = self else {
                    completionHandler(false)
                    return
                }
                let url = self.baseURL + "events_users/\(eventUserId)"
                self._modifyEvent(url: url, method: method, completiondHandler: completionHandler)
            }
        default:
            completionHandler(false)
        }
    }
    
    private func _modifyEvent(url: String, method: HTTPMethod, completiondHandler: @escaping (Bool) -> Void) {
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
