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

/**
 `API42Manager.shared` is used for all calls to 42's API
 */
class API42Manager {
    
    /// Shared instance of API42Manager
    static let shared = API42Manager()
    /// API app ID key
    let clientId = "YOUR_42_API_APP_UID"
    /// API app secret key
    let clientSecret = "YOUR_42_API_APP_SECRET"
    /// Redirect URL called by api after OAuth
    let redirectURI = "com.femaury.swifty://oauth2callback"
    /// Secret state used to verify API calls
    let state = "super_long_secret_state"
    
    /// Keychain store instance
    let keychain = KeychainSwift()
    /// Keychain key for storing access token
    let keychainAccessKey = "SwiftyAccessToken"
    /// Keychain key for storing refresh token
    let keychainRefreshKey = "SwiftyRefreshToken"
    
    /// Access token received by API after OAuth
    var OAuthAccessToken: String?
    /// Refresh token received by API after OAuth
    var OAuthRefreshToken: String?
    /// Closure called after completion of the OAuth flow
    var OAuthTokenCompletionHandler: ((CustomError?) -> Void)?
    /// Closure called once the logged in user's coalition color is obtained
    var coalitionColorCompletionHandler: ((UIColor?) -> Void)?
    /// Closure called once the logged in user's information is obtained
    var userProfileCompletionHandler: ((UserProfile?) -> Void)?
    
    /// Contains all the information about the logged in user
    var userProfile: UserProfile?
    /// Coalition color of logged in user
    var coalitionColor: UIColor?
    /// Coalition logo of logged in user
    var coalitionLogo: String?
    /// Coalition name of logged in user
    var coalitionName: String?
    
    /// Holds all locations for multiple API calls
    var locationData: [JSON] = []
    /// Holds all achievements for multiple API calls
    var allAchievements: [String: Achievement] = [:]
    
    /// Default initialization checks if user is logged in to get all required data for the API
    init() {
        OAuthAccessToken = keychain.get(keychainAccessKey)
        OAuthRefreshToken = keychain.get(keychainRefreshKey)
        if hasOAuthToken() {
            setupAPIData()
        }
    }
    
    /**
     Sets up the instance with logged in user info
     
     Calls `/v2/me` to create instance of `UserProfile` and get coalition info
     */
    func setupAPIData() {
        
        // Get info about current token user
        request(url: "https://api.intra.42.fr/v2/me") { (responseJSON) in
            guard let data = responseJSON else { return }
            self.userProfile = UserProfile(data: data)
            
            let userId = data["id"].intValue
            self.getCoalitionInfo(forUserId: userId, completionHandler: { (name, color, logo) in
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
    
    /// Checks if instance has an access token for the API
    func hasOAuthToken() -> Bool {
        guard let token = self.OAuthAccessToken else { return false }
        return !token.isEmpty
    }
    
    /// Completely removes all references of API tokens from the app and keychain storage (log out)
    func clearTokenKeys() {
        OAuthAccessToken = nil
        OAuthRefreshToken = nil
        keychain.delete(keychainAccessKey)
        keychain.delete(keychainRefreshKey)
    }
    
    /**
     Sends user back to login page with error message
     
     Usually called when the API unauthorizes the user token.
     
     - Parameter error: `CustomError` containing description to be shown to user on login page
     */
    func handleAPIErrors(error: CustomError) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        viewController.errorMessage = error.description
        print(error)
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    /**
     Creates a UIAlertController and presents it with the message
     
     Will always be presented by current top level controller.
     Usually called for non fatal API errors, like internet connection problems.
     
     - Parameter message: `String` containing the message used to notify the user of an error
     
     - Note: Until the app gets an official key, this is called whenever there are too many calls
     to the API (i.e. more than 2/seconds)
     */
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
    
    /// Logs out user by clearing the token keys and presenting the login page
    func logoutUser() {
        clearTokenKeys()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    // MARK: - Generic Request Method
    
    /**
     Boilerplate request to 42's API used by all methods making API calls
     
     Checks if the user is logged in, then percent encodes the URL and adds the token to headers.
     Parses the request's response as JSON, then checks for errors.
     
     - Note: If the token is expired, attempts once to refresh it and on success, retries the request.
     If token refresh fails, clears the token keys and returns to login page.
     
     - Parameter url: URL to make the request to
     - Parameter completionHandler: Closure returning `JSON` on success, or `nil` on error
     */
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
    
    // TEMPORARY: - Simple data return calls 
    
    func getProject(withId id: Int, completionHandler: @escaping (JSON?) -> Void) {
        let projectURL = "https://api.intra.42.fr/v2/projects/\(id)"
        
        request(url: projectURL) { (data) in
            completionHandler(data)
        }
    }
}
