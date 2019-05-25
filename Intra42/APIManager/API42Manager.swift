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
    let clientId = "YOUR_42_API_APP_UID"
    let clientSecret = "YOUR_42_API_APP_SECRET"
    let redirectURI = "com.femaury.swifty://oauth2callback"
    let state = "super_long_secret_state"
    
    let keychain = KeychainSwift()
    let keychainAccessKey = "SwiftyAccessToken"
    let keychainRefreshKey = "SwiftyRefreshToken"
    
    var OAuthAccessToken: String?
    var OAuthRefreshToken: String?
    var OAuthTokenCompletionHandler: ((CustomError?) -> Void)?
    var coalitionColorCompletionHandler: ((UIColor?) -> Void)?
    var userProfileCompletionHandler: ((UserProfile?) -> Void)?
    
    var userProfile: UserProfile?
    var coalitionColor: UIColor?
    var coalitionLogo: String?
    var coalitionName: String?
    
    var locationData: [JSON] = []
    var allAchievements: [String: Achievement] = [:]
    
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
            self.getCoalitionInfo(withUserId: userId, completionHandler: { (name, color, logo) in
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
    
    // MARK: - Generic Request Method
    
    func request(url: String, completionHandler: @escaping ((JSON?) -> Void)) {
        if hasOAuthToken() {
            let headers = ["authorization": "Bearer \(OAuthAccessToken!)"]
            let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

            Alamofire.request(encodedURL, headers: headers).responseJSON { (response) in
                if let error = response.error {
                    // Unable to parse "429 Too Many Requests (Spam Rate Limit Exceeded)" as JSON
                    // Will be fixed when app gets approved by 42 API team
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
                        } else if message.contains("not authorized") || message.contains("was revoked") {
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
    
    // MARK: - Simple data return calls
    
    func getProject(withId id: Int, completionHandler: @escaping (JSON?) -> Void) {
        let projectURL = "https://api.intra.42.fr/v2/projects/\(id)"
        
        request(url: projectURL) { (data) in
            completionHandler(data)
        }
    }
    
    func getTeam(withId id: Int, completionHandler: @escaping (JSON?) -> Void) {
        let projectURL = "https://api.intra.42.fr/v2/teams?filter[id]=\(id)"
        
        request(url: projectURL) { (data) in
            completionHandler(data)
        }
    }
    
    func getTeam(withUserId id: Int, projectId: Int, completionHandler: @escaping (JSON?) -> Void) {
        let projectURL = "https://api.intra.42.fr/v2/users/\(id)/teams?filter[project_id]=\(projectId)"
        
        request(url: projectURL) { (data) in
            completionHandler(data)
        }
    }
}
