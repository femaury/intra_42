//
//  42APIManager.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import KeychainSwift

public enum HTTPMethod: String {

    case get = "GET"
    case put = "PUT"
    case patch = "PATCH"
    case post = "POST"
    case delete = "DELETE"
}

/**
 `API42Manager.shared` is used for all calls to 42's API
 */
class API42Manager {
    
    /// Shared instance of API42Manager
    static let shared = API42Manager()
    /// Base URL for API
    let baseURL = "https://api.intra.42.fr/v2/"
    /// URL for API OAuth flow
    let oAuthURL = "https://api.intra.42.fr/oauth/token"
    /// API app ID key
    let clientId = "YOUR_42_API_APP_UID"
    /// API app secret key
    let clientSecret = "YOUR_42_API_APP_SECRET"
    /// Redirect URL called by api after OAuth
    let redirectURI = "com.femaury.swifty://oauth2callback"
    /// Secret state used to verify API calls
    var state = "super_long_secret_state"
    
    /// Keychain store instance
    let keychain = KeychainSwift()
    /// Keychain key for storing access token
    let keychainAccessKey = "SwiftyAccessToken"
    /// Keychain key for storing refresh token
    let keychainRefreshKey = "SwiftyRefreshToken"

    /// Reference to alert controller to update title in real time (timer)
    var requestsAlertController = UIAlertController()
    /// Timer for requests alert controller
    var requestsTimer: Timer?
    /// Controller handling OAuth
    var webViewController: WebViewController?
    /// Access token received from API after OAuth
    var oAuthAccessToken: String? {
        get { keychain.get(keychainAccessKey) }
        set {
            if let value = newValue {
                keychain.set(value, forKey: keychainAccessKey)
            } else {
                keychain.delete(keychainAccessKey)
            }
        }
    }
    /// Refresh token received from API after OAuth
    var oAuthRefreshToken: String? {
        get { keychain.get(keychainRefreshKey) }
        set {
            if let value = newValue {
                keychain.set(value, forKey: keychainRefreshKey)
            } else {
                keychain.delete(keychainRefreshKey)
            }
        }
    }
    /// Closure called after completion of the OAuth flow
    var oAuthTokenCompletionHandler: ((CustomError?) -> Void)?
    /// Closure called once the logged in user's coalition color is obtained
    var coalitionColorCompletionHandler: ((UIColor?) -> Void)?
    /// Closure called once the logged in user's information is obtained
    var userProfileCompletionHandler: [((UserProfile?) -> Void)] = []
    
    /// Contains all the information about the logged in user
    var userProfile: UserProfile?
    /// Coalition color of logged in user
    var coalitionColor: UIColor?
    /// Coalition logo of logged in user
    var coalitionBgURL: String?
    /// Coalition name of logged in user
    var coalitionName: String?

    /// Computed from UserDefaults and set by user in settings
    var preferedPrimaryColor: UIColor? {
        get {
            guard let hex = UserDefaults.standard.string(forKey: "SwiftyPrimaryColorHex") else {
                return coalitionColor
            }
            return UIColor(hexRGB: hex)
        }
        set {
            let hex = newValue?.toHex
            UserDefaults.standard.set(hex, forKey: "SwiftyPrimaryColorHex")
        }
    }
    
    /// Holds all locations for multiple API calls
    var locationData: [JSON] = []
    /// Holds all achievements for multiple API calls
    var allAchievements: [String: Achievement] = [:]
    /// Holds all projects for multiple API calls
    var allProjects: [JSON] = []
    
    /// Default initialization checks if user is logged in to get all required data for the API
    init() {
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
        request(url: baseURL + "me") { (responseJSON) in
            guard let data = responseJSON else { return }
            self.userProfile = UserProfile(data: data)
            
            let userId = data["id"].intValue
            self.getCoalitionInfo(forUserId: userId, completionHandler: { (name, color, bgURL) in
                self.coalitionName = name
                self.coalitionColor = color
                self.coalitionBgURL = bgURL
                
                for finishHandler in self.userProfileCompletionHandler {
                    finishHandler(self.userProfile)
                }
                if let colorFinishHandler = self.coalitionColorCompletionHandler {
                    colorFinishHandler(self.preferedPrimaryColor)
                }
            })
        }
    }
    
    /// Checks if instance has an access token for the API
    func hasOAuthToken() -> Bool {
        guard let token = oAuthAccessToken else { return false }
        return !token.isEmpty
    }
    
    /// Completely removes all references of API tokens from the app and keychain storage (log out)
    func clearTokenKeys() {
        oAuthAccessToken = nil
        oAuthRefreshToken = nil
    }
    
    func clearIntraSessionCookies() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies { // where cookie.name == "_intra_42_session_production" {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        if let cookieStore = webViewController?.webView.configuration.websiteDataStore.httpCookieStore {
            cookieStore.getAllCookies { cookies in
                for cookie in cookies { // where cookie.name == "_intra_42_session_production" {
                    cookieStore.delete(cookie)
                }
            }
        }
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
        let alert = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        getTopViewController()?.present(alert, animated: true, completion: nil)
    }
    
    /// Logs out user by clearing the token keys and presenting the login page
    func logoutUser() {
        clearTokenKeys()
        clearIntraSessionCookies()
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
    func request(url: String, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, completionHandler: @escaping ((JSON?) -> Void)) {
        if hasOAuthToken(),
            let token = oAuthAccessToken,
            let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let realURL = URL(string: encodedURL) {
            
            var request = URLRequest(url: realURL)
            request.cachePolicy = cachePolicy
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Request Error:", error)
                        self.showErrorAlert(message: "There was a problem with 42's API...")
                        completionHandler(nil)
                        return
                    }
                    guard let data = data, let valueJSON = try? JSON(data: data) else {
                        print("Request Error: Couldn't get data after request...")
                        print(response ?? "NO RESPONSE")
                        if let res = response as? HTTPURLResponse, res.statusCode == 429 {
                            self.handleTooManyRequests(url: url, completionHandler: completionHandler)
                            return
                        } else {
                            self.showErrorAlert(message: "There was a problem with 42's API...")
                            completionHandler(nil)
                            return
                        }
                    }
                
                    if valueJSON["error"].string != nil {
                        print("Error returned:", valueJSON)
                        print("After calling:", encodedURL)
                        if let message = valueJSON["message"].string {
                            if message.contains("token expired") {
                                self.refreshOAuthToken(completionHandler: { (success) in
                                    if success == true {
                                        self.request(url: url, completionHandler: completionHandler)
                                    } else {
                                        let error = CustomError(title: "Refresh Token Error",
                                                                description: "Couldn't refresh OAuth Token...",
                                                                code: -1)
                                        self.clearTokenKeys()
                                        self.handleAPIErrors(error: error)
                                    }
                                    return
                                })
                            } else if message.contains("not authorized") || message.contains("was revoked") {
                                self.showErrorAlert(message: "You are not authorized to access this.")
                                completionHandler(nil)
                                return
                            }
                        }
//                        self.showErrorAlert(message: "There was a problem with 42's API...")
                        completionHandler(nil)
                        return
                    }
                    
//                    if let res = response as? HTTPURLResponse {
//                        let headers = res.allHeaderFields
//                        print(headers["Link"])
//                    }
                    completionHandler(valueJSON)
                }
            }.resume()
        } else {
            completionHandler(nil)
        }
    }
    
    fileprivate func handleTooManyRequests(url: String, completionHandler: @escaping (JSON?) -> Void) {
        requestsAlertController = UIAlertController(
        title: "Error: Too many requests to server",
        message: "Retrying automatically in 5...",
        preferredStyle: .alert)
        
        let task = DispatchWorkItem {
            self.requestsAlertController.dismiss(animated: true)
            self.request(url: url, completionHandler: completionHandler)
        }

        let action = UIAlertAction(title: "Retry now", style: .default) { _ in
            task.cancel()
            self.requestsTimer?.invalidate()
            self.request(url: url, completionHandler: completionHandler)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            task.cancel()
            self.requestsTimer?.invalidate()
            completionHandler(nil)
        }
        requestsAlertController.addAction(action)
        requestsAlertController.addAction(cancel)
        getTopViewController()?.present(requestsAlertController, animated: true) {
            let timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(self._requestsAlertCountdown),
                userInfo: nil,
                repeats: true)
            self.requestsTimer = timer
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    @objc fileprivate func _requestsAlertCountdown() {
        if let string = requestsAlertController.message {
            if let counter = Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                if counter > 0 {
                    requestsAlertController.message = "Retrying automatically in \(counter - 1)..."
                    return
                }
            }
        }
        requestsTimer?.invalidate()
    }
    
    func getTopViewController() -> UIViewController? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var topViewController = appDelegate.window?.rootViewController
        
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController
    }
}
