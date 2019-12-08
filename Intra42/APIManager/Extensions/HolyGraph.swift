//
//  HolyGraph.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    
    /**
    Gets all projects and coordinates for holy graph.
    
    Uses 42's private API with the cookie obtained from user login for OAuth.
    */
    func getProjectCoordinates(forUser user: String, campusId: Int, cursusId: Int, completionHandler: @escaping ([JSON]) -> Void) {
        let urlString = "https://projects.intra.42.fr/project_data.json?cursus_id=\(cursusId)&campus_id=\(campusId)&login=\(user)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let cookies = HTTPCookieStorage.shared.cookies {
                    for cookie in cookies where cookie.name == "_intra_42_session_production" {
                        let properties: [HTTPCookiePropertyKey: Any] = [
                            HTTPCookiePropertyKey.domain: cookie.domain,
                            HTTPCookiePropertyKey.secure: cookie.isSecure,
                            HTTPCookiePropertyKey.expires: Date(timeIntervalSinceNow: 60 * 60 * 24 * 365),
                            HTTPCookiePropertyKey.name: cookie.name,
                            HTTPCookiePropertyKey.path: cookie.path,
                            HTTPCookiePropertyKey.value: cookie.value,
                            HTTPCookiePropertyKey.version: cookie.version
                        ]
                        if let newCookie = HTTPCookie(properties: properties) {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                            HTTPCookieStorage.shared.setCookie(newCookie)
                        }
                    }
                }
                guard error == nil, let data = data else {
                    print("ERROR")
                    API42Manager.shared.showErrorAlert(message: "There was a problem with 42's API...")
                    return
                }
                guard let valueJSON = try? JSON(data: data) else {
                    print("Request Error: Couldn't get data after request...")
                    API42Manager.shared.showErrorAlert(message: "There was a problem with 42's API...")
                    return
                }
                var projects = valueJSON.arrayValue
//                print("PROJECTS FOR CURSUS ID \(cursusId)")
//                print(projects)
                switch cursusId {
                case 1:
                    self._sortCursus1(&projects)
                case 21:
                    self._sortCursus21(&projects)
                default:
                    break
                }
                completionHandler(projects)
            }.resume()
        }
    }
    
    fileprivate func _sortCursus1(_ projects: inout [JSON]) {
        guard projects.count > 1 else { return }
        var first: JSON = projects[1]
        var second: JSON = projects[0]
        for project in projects {
            let kind = project["kind"].stringValue
            if kind == "first_internship" {
                first = project
                projects.remove(at: projects.firstIndex(of: project)!)
            } else if kind == "second_internship" {
                second = project
                projects.remove(at: projects.firstIndex(of: project)!)
            }
        }
        projects.insert(first, at: 0)
        projects.insert(second, at: 0)
    }
    
    fileprivate func _sortCursus21(_ projects: inout [JSON]) {
        var first: [JSON] = []
        var second: [JSON] = []
        var third: [JSON] = []
        var fourth: [JSON] = []
        var fifth: [JSON] = []
        var sixth: [JSON] = []
        var zero: [JSON] = []
        for project in projects {
            let slug = project["slug"].stringValue
            switch slug {
            case "ft_transcendance", "exam-rank-06":
                sixth.append(project)
                projects.remove(at: projects.firstIndex(of: project)!)
            case "ft_containers", "exam-rank-05", "webserv", "ft_irc":
                fifth.append(project)
                projects.remove(at: projects.firstIndex(of: project)!)
            case "42cursus-philosophers",
                 "exam-rank-04",
                 "cpp-module-00",
                 "cpp-module-01",
                 "cpp-module-02",
                 "cpp-module-03",
                 "cpp-module-04",
                 "cpp-module-05",
                 "cpp-module-06",
                 "cpp-module-07",
                 "cpp-module-08":
                fourth.append(project)
                projects.remove(at: projects.firstIndex(of: project)!)
            case "libasm", "exam-rank-03", "42cursus-minishell", "ft_services":
                third.append(project)
                projects.remove(at: projects.firstIndex(of: project)!)
            case "ft_server", "exam-rank-02", "cub3d", "minirt":
                second.append(project)
                projects.remove(at: projects.firstIndex(of: project)!)
            case "netwhat", "42cursus-ft_printf", "42cursus-get_next_line":
                first.append(project)
                projects.remove(at: projects.firstIndex(of: project)!)
            case "42cursus-libft":
                zero.append(project)
                projects.remove(at: projects.firstIndex(of: project)!)
            default:
                continue
            }
        }
        sixth.sort { $0["name"].stringValue.contains("Exam") && !$1["name"].stringValue.contains("Exam") }
        fifth.sort { $0["name"].stringValue.contains("Exam") && !$1["name"].stringValue.contains("Exam") }
        fourth.sort { $0["name"].stringValue.contains("Exam") && !$1["name"].stringValue.contains("Exam") }
        third.sort { $0["name"].stringValue.contains("Exam") && !$1["name"].stringValue.contains("Exam") }
        second.sort { $0["name"].stringValue.contains("Exam") && !$1["name"].stringValue.contains("Exam") }
        first.sort { $0["name"].stringValue.contains("printf") && !$1["name"].stringValue.contains("printf") }
        projects.append(contentsOf: sixth)
        projects.append(contentsOf: fifth)
        projects.append(contentsOf: fourth)
        projects.append(contentsOf: third)
        projects.append(contentsOf: second)
        projects.append(contentsOf: first)
        projects.append(contentsOf: zero)
    }
}
