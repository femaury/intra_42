//
//  42APIManager.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift

class API42Manager {
    
    static let shared = API42Manager()
    private let clientID = "YOUR_42_API_APP_UID"
    private let clientSecret = "YOUR_42_API_APP_SECRET"
    private let redirectURI = "com.femaury.swifty://oauth2callback"
    private let state = "super_long_secret_state"
    
    private let keychain = KeychainSwift()
    private let keychainAccessKey = "SwiftyAccessToken"
    private let keychainRefreshKey = "SwiftyRefreshToken"
    
    private var OAuthAccessToken: String?
    private var OAuthRefreshToken: String?
    var OAuthTokenCompletionHandler: ((CustomError?) -> Void)?
    var coalitionColorCompletionHandler: ((UIColor?) -> Void)?
    var userProfileCompletionHandler: ((UserProfile?) -> Void)?
    
    var userProfile: UserProfile?
    var coalitionColor: UIColor?
    var coalitionLogo: String?
    var coalitionName: String?
    
    var locationData: [JSON] = []
    var allAchievements: [String : Achievement] = [:]
    
    init() {
        OAuthAccessToken = keychain.get(keychainAccessKey)
        OAuthRefreshToken = keychain.get(keychainRefreshKey)
        if hasOAuthToken() {
            setupAPIData()
        }
    }
    
    func setupAPIData() {
        
        // Get info about current token user
        request(url: "https://api.intra.42.fr/v2/me") { (responseJSON) in
            guard let data = responseJSON else { return }
            self.userProfile = UserProfile(data: data)
            
            let userId = data["id"].intValue
            self.getCoalitionInfoFor(userId: userId, completionHandler: { (name, color, logo) in
                self.coalitionName = name
                self.coalitionColor = color
                self.coalitionLogo = logo
                
                if let finishHandler = self.userProfileCompletionHandler {
                    finishHandler(self.userProfile)
                }
                if let colorFinishHandler = self.coalitionColorCompletionHandler {
                    colorFinishHandler(color)
                }
            })
        }
    }
    
    func hasOAuthToken() -> Bool {
        guard let token = self.OAuthAccessToken else { return false }
        return !token.isEmpty
    }
    
    func clearTokenKeys() {
        OAuthAccessToken = nil
        OAuthRefreshToken = nil
        keychain.delete(keychainAccessKey)
        keychain.delete(keychainRefreshKey)
    }
    
    func handleAPIErrors(error: CustomError) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        viewController.errorMessage = error.description
        print(error)
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    func showErrorAlert(message: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var topViewController = appDelegate.window?.rootViewController
        
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        let alert = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topViewController?.present(alert, animated: true, completion: nil)
    }
    
    func logoutUser() {
        clearTokenKeys()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    // MARK: - API Calls
    
    func request(url: String, completionHandler: @escaping ((JSON?) -> Void)) {
        if hasOAuthToken() {
            let headers = ["authorization": "Bearer \(OAuthAccessToken!)"]
            let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            Alamofire.request(encodedURL, headers: headers).responseJSON { (response) in
                if let error = response.error {
                    print("Request Error:", error)
                    self.showErrorAlert(message: "There was a problem with 42's API...")
                    completionHandler(nil)
                    return
                }
                response.result.ifFailure {
                    print("Response is a failure")
                    completionHandler(nil)
                    return
                }

                guard let value = response.result.value else { return }
                let valueJSON = JSON(value)
                
                if valueJSON["error"].string != nil {
                    print("Error returned:", valueJSON)
                    print("After calling:", encodedURL)
                    if let message = valueJSON["message"].string {
                        if message.contains("token expired") {
                            self.refreshOAuthToken(completionHandler: { (success) in
                                if success == true {
                                    self.request(url: url, completionHandler: completionHandler)
                                } else {
                                    let error = CustomError(title: "Refresh Token Error", description: "Couldn't refresh OAuth Token...", code: -1)
                                    self.clearTokenKeys()
                                    self.handleAPIErrors(error: error)
                                }
                            })
                        } else if message.contains("not authorized") {
                            let error = CustomError(title: "Authorization Error", description: "Token was unauthorized by API...", code: -1)
                            self.clearTokenKeys()
                            self.handleAPIErrors(error: error)
                        }
//                                                TODO: Handle other error messages
                    }
                    return
                }
                
                completionHandler(valueJSON)
            }
        } else {
            completionHandler(nil)
        }
    }
    
    func getCoalitionInfoFor(userId: Int, completionHandler: @escaping (String, UIColor?, String) -> Void) {
        request(url: "https://api.intra.42.fr/v2/users/\(userId)/coalitions") { (responseJSON) in
            guard let data = responseJSON, data.isEmpty == false else {
                completionHandler("default", IntraTeal, "")
                return
            }
            print(data)
            var lowestId = data.arrayValue[0]["id"].intValue
            var hexColor = ""
            var coaLogo = ""
            var coaSlug = ""
            
            for coalition in data.arrayValue {
                let id = coalition["id"].intValue
                if id <= lowestId {
                    lowestId = id
                    hexColor = coalition["color"].stringValue
                    coaLogo = coalition["image_url"].stringValue
                    coaSlug = coalition["slug"].stringValue.replacingOccurrences(of: "-", with: "_")
                    coaSlug = coaSlug.replacingOccurrences(of: "piscine_c_lyon_", with: "")
                }
            }
            
            completionHandler(coaSlug, UIColor(hexRGB: hexColor), coaLogo)
        }
    }
    
    // TODO: Get application API token officialized to make more than 2 requests per second.
    func searchUsersWith(string: String, completionHander: @escaping (JSON?, SearchSection) -> Void) {
        let loginURL = "https://api.intra.42.fr/v2/users?search[login]=\(string)&sort=login&page[size]=100"
        let firstNameURL = "https://api.intra.42.fr/v2/users?search[first_name]=\(string)&sort=login&page[size]=100"
        let lastNameURL = "https://api.intra.42.fr/v2/users?search[last_name]=\(string)&sort=login&page[size]=100"

        request(url: loginURL) { (responseJSON) in
            completionHander(responseJSON, .username)
        }
        request(url: firstNameURL) { (responseJSON) in
            completionHander(responseJSON, .firstName)
            
            self.request(url: lastNameURL) { (responseJSON) in
                completionHander(responseJSON, .lastName)
            }
        }
    }
    
    func getLogsForUserWith(id: Int, completionHandler: @escaping ([LocationLog]) -> Void) {
        API42Manager.shared.request(url: "https://api.intra.42.fr/v2/locations?filter[user_id]=\(id)&page[size]=100") { (data) in
            guard let logs = data?.arrayValue else {
                completionHandler([])
                return
            }
            
            var previousDay = ""
            var locationLogs: [LocationLog] = []
            for log in logs {
                let location = log["host"].stringValue
                let dateString = log["begin_at"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                if let dateUTC = dateFormatter.date(from: dateString) {
                    let endDateUTC = dateFormatter.date(from: log["end_at"].stringValue) ?? Date()
                    dateFormatter.dateFormat = "MMMM d, yyyy"
                    dateFormatter.timeZone = TimeZone.current
                    let day = dateFormatter.string(from: dateUTC)
                    
                    dateFormatter.dateFormat = "HH:mm"
                    let beginHour = dateFormatter.string(from: dateUTC)
                    let hours = Int(endDateUTC.timeIntervalSince(dateUTC)) / 3600
                    let minutes = (Int(endDateUTC.timeIntervalSince(dateUTC)) / 60) % 60
                    var timeInterval: String
                    if hours == 0 {
                        timeInterval = "\(minutes) minute"
                        if minutes != 1 {
                            timeInterval += "s"
                        }
                    } else {
                        timeInterval = "\(hours) hour"
                        if hours != 1 {
                            timeInterval += "s"
                        }
                    }
                    var endHour: String
                    if log["end_at"] == JSON.null {
                        endHour = "now"
                    } else {
                        endHour = dateFormatter.string(from: endDateUTC)
                    }
                    
                    let calendar = Calendar.current
                    let dayOne = calendar.startOfDay(for: dateUTC)
                    let dayTwo = calendar.startOfDay(for: endDateUTC)
                    
                    if let daysDiff = Calendar.current.dateComponents([.day], from: dayOne, to: dayTwo).day {
                        if daysDiff > 0 {
                            endHour += " (+\(daysDiff))"
                        }
                    }
                    let timeString = "From \(beginHour) to \(endHour) for \(timeInterval)"
                    
                    if day == previousDay {
                        locationLogs.last?.logs.append((location, timeString))
                    } else {
                        previousDay = day
                        locationLogs.append(LocationLog(day: day, logs: [(location, timeString)]))
                    }
                }
                completionHandler(locationLogs)
            }
        }
    }
    
    // TODO: Find access to exam events (Currently unauthorized)
    func getFutureEventsFor(campusId: Int, cursusId: Int, completionHandler: @escaping ([JSON]) -> Void) {
        let eventsURL = "https://api.intra.42.fr/v2/campus/\(campusId)/cursus/\(cursusId)/events?filter[future]=true&page[size]=100"
        
        request(url: eventsURL) { (eventsData) in
            guard let eventsData = eventsData else {
                completionHandler([])
                return
            }
            print(eventsData)
            completionHandler(eventsData.arrayValue)
        }
    }
    
    func getFutureEventsFor(userId: Int, completionHandler: @escaping ([JSON]) -> Void) {
        let eventsURL = "https://api.intra.42.fr/v2/users/\(userId)/events?filter[future]=true"
        
        request(url: eventsURL) { (eventsData) in
            guard let eventsData = eventsData else {
                completionHandler([])
                return
            }
            completionHandler(eventsData.arrayValue)
        }
    }
    
    func getLocationsFor(campusId: Int, page: Int, completionHandler: @escaping ([JSON]) -> Void) {
        if page == 1 {
            locationData = [] // Reset array for each first call to getLocationsFor()
        }
        let locationURL = "https://api.intra.42.fr/v2/campus/\(campusId)/locations?filter[active]=true&page[number]=\(page)&page[size]=100"
        
        request(url: locationURL) { (data) in
            guard let data = data  else {
                completionHandler([])
                return
            }
            self.locationData += data.arrayValue
            if data.arrayValue.count == 100 {
                print("Location Page \(page)")
                self.getLocationsFor(campusId: campusId, page: page + 1, completionHandler: completionHandler)
            } else {
                completionHandler(self.locationData)
            }
        }
    }
    
    func getAllAchievements(completionHandler: @escaping ([String : Achievement]) -> Void) {
        let achievementsURL = "https://api.intra.42.fr/v2/achievements?page[size]=100"
        
        request(url: achievementsURL) { (data) in
            guard let data = data else {
                completionHandler([:])
                return
            }
            var achievementsData = data.arrayValue
            if achievementsData.count == 100 {
                let page2URL = achievementsURL + "&page[number]=2"
                
                self.request(url: page2URL, completionHandler: { (data) in
                    guard let data = data else {
                        self.parseAchievementsData(achievementsData, completionHandler)
                        return
                    }
                    achievementsData += data.arrayValue
                    self.parseAchievementsData(achievementsData, completionHandler)
                })
            } else {
                self.parseAchievementsData(achievementsData, completionHandler)
            }
        }
    }
    
    func parseAchievementsData(_ data: [JSON], _ completionHandler: ([String : Achievement]) -> Void) {
        var achievements: [String : Achievement] = [:]

        for achievement in data {
            if MoscowAchievementIds.contains(achievement["id"].intValue) { continue }
            let newAchievement = Achievement(achievement: achievement)
            let name = newAchievement.name
            if let parent = achievements[name] {
                if parent.successCount > newAchievement.successCount {
                    newAchievement.subs += parent.subs
                    parent.subs = []
                    newAchievement.subs.append(parent)
                    achievements[name] = newAchievement
                } else {
                    parent.subs.append(newAchievement)
                }
            } else {
                achievements[name] = newAchievement
            }
        }
        completionHandler(achievements)
        self.allAchievements = achievements
    }
    
    func getScales(completionHandler: @escaping ([JSON]) -> Void) {
        let scalesURL = "https://api.intra.42.fr/v2/me/scale_teams?page[size]=100"
        
        request(url: scalesURL) { (data) in
            guard let data = data?.array else {
                completionHandler([])
                return
            }
            completionHandler(data)
        }
    }
    
    func getProfilePicture(forLogin login: String, completionHandler: @escaping (UIImage?) -> Void) {
        let urlString = "https://cdn.intra.42.fr/users/medium_\(login).jpg"
        let defaultImage = UIImage(named: "42_default")
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let err = error {
                    print("Error downloading image: \(err)")
                    completionHandler(defaultImage)
                    return
                }
                guard let imgData = data, let image = UIImage(data: imgData) else {
                        completionHandler(defaultImage)
                        return
                }
                completionHandler(image)
            }.resume()
        } else {
            completionHandler(defaultImage)
        }
    }
    
    // MARK: - OAuth Flow
    
    func startOAuth2Login() {
        let authPath = "https://api.intra.42.fr/oauth/authorize?client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=public&state=\(state)&response_type=code"
        
        if hasOAuthToken() {
            if let completionHandler = OAuthTokenCompletionHandler {
                completionHandler(nil)
            }
            return
        }
        
        if let authURL = URL(string: authPath) {
            UIApplication.shared.open(authURL, options: [:])
        }
    }
    
    func processOAuthResponse(_ url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else { return }
        
        var codeValue: String?
        
        for item in queryItems {
            if item.name.lowercased() == "code" {
                codeValue = item.value
            } else if item.name.lowercased() == "state" {
                if item.value != state { return }
            }
        }
        guard let code = codeValue else { return }
        
        let tokenURL = "https://api.intra.42.fr/oauth/token"
        let tokenParams = [
            "grant_type": "authorization_code",
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectURI,
            "state": state
        ]
        Alamofire.request(tokenURL, method: .post, parameters: tokenParams).responseJSON { (response) in
            if let error = response.error {
                print(error)
                if let completionHandler = self.OAuthTokenCompletionHandler {
                    let customError = CustomError(title: "Get Token Error", description: "Couldn't get access token from 42's API", code: -1)
                    completionHandler(customError)
                }
                return
            }
            
            print("Getting new token...")
            
            guard let value = response.result.value else { return }
            let valueJSON = JSON(value)
            
            print(valueJSON)
            
            guard valueJSON["token_type"].string == "bearer" else { return } // Is not bearer
            guard
                let accessToken = valueJSON["access_token"].string,
                let refreshToken = valueJSON["refresh_token"].string
            else { return }

            self.OAuthAccessToken = accessToken
            self.OAuthRefreshToken = refreshToken
            
            self.keychain.set(accessToken, forKey: self.keychainAccessKey)
            self.keychain.set(refreshToken, forKey: self.keychainRefreshKey)
            
            if let completionHandler = self.OAuthTokenCompletionHandler {
                self.setupAPIData()
                completionHandler(nil)
            }
        }
    }
    
    func refreshOAuthToken(completionHandler: @escaping ((Bool) -> Void)) {
        keychain.delete(keychainAccessKey)
        
        print("Refreshing token...")
        
        guard let refreshToken = OAuthRefreshToken else {
            startOAuth2Login()
            return
        }
        
        let tokenURL = "https://api.intra.42.fr/oauth/token"
        let tokenParams = [
            "grant_type": "refresh_token",
            "client_id": clientID,
            "client_secret": clientSecret,
            "refresh_token": refreshToken,
            "redirect_uri": redirectURI,
            "state": state
        ]
        
        Alamofire.request(tokenURL, method: .post, parameters: tokenParams).responseJSON { (response) in
            if let error = response.error {
                print(error)
                completionHandler(false)
                return
            }
            
            guard let value = response.result.value else { return }
            let valueJSON = JSON(value)
            
            guard valueJSON["token_type"].string == "bearer" else { return } // Is not bearer
            guard
                let accessToken = valueJSON["access_token"].string,
                let refreshToken = valueJSON["refresh_token"].string
            else { return }
            
            self.OAuthAccessToken = accessToken
            self.OAuthRefreshToken = refreshToken
            
            self.keychain.set(accessToken, forKey: self.keychainAccessKey)
            self.keychain.set(refreshToken, forKey: self.keychainRefreshKey)
            
            completionHandler(true)
        }
    }
}
