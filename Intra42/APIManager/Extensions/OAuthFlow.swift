//
//  OAuthFlow.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SafariServices
import WebKit

extension API42Manager {
    /**
     Starts OAuth login flow
     
     If user already has a token, calls `OAuthTokenCompletionHandler` with `nil`.
     Otherwise opens 42's API OAuth page in safari to prompt user to login.
     */
    func startOAuth2Login() {
        state = UUID().uuidString
        let authPath = "https://api.intra.42.fr/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectURI)&state=\(state)&response_type=code&scope=public+profile+projects"
        
        if hasOAuthToken() {
            if let completionHandler = OAuthTokenCompletionHandler {
                completionHandler(nil)
            }
            return
        }
                
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
            self.webViewController = controller
            _ = controller.view
            controller.load(authPath)
            getTopViewController()?.present(controller, animated: true, completion: nil)
        }
    }
    
    /**
     Processes OAuth's login response.
     
     Called by `AppDelegate` when `redirectURI` is called by 42's API.
     Verifies that the response is valid then calls the API to received the user's token.
     Stores the access and refresh tokens in the KeyChain, then gets all data about logged
     in user.
     
     If error, calls `OAuthTokenCompletionHandler` with `CustomError`.
     Otherwise calls the handler with `nil`.
     
     - Parameter url: URL used to open the app. Should be `redirectURI`
     */
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
            } else if item.name.lowercased() == "error" {
                if let completionHandler = self.OAuthTokenCompletionHandler {
                    let customError = CustomError(title: "API Authorization", description: "You did not authorize this app.", code: -1)
                    completionHandler(customError)
                }
                self.webViewController?.dismiss(animated: true, completion: nil)
                return
            }
        }
        guard let code = codeValue else {
            self.webViewController?.dismiss(animated: true, completion: nil)
            return
        }
        
        let url = URL(string: "https://api.intra.42.fr/oauth/token")!
        let tokenParams = [
            "grant_type": "authorization_code",
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectURI,
            "state": state
        ]
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = tokenParams.percentEscaped().data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                guard error == nil, let data = data, let valueJSON = try? JSON(data: data) else {
                    if let error = error {
                        print("OAuth Response Error: \(error)")
                    }
                    if let completionHandler = self.OAuthTokenCompletionHandler {
                        let customError = CustomError(title: "Get Token Error", description: "Couldn't get access token from 42's API", code: -1)
                        completionHandler(customError)
                    }
                    self.webViewController?.dismiss(animated: true, completion: nil)
                    return
                }
            
                guard valueJSON["token_type"].string == "bearer",
                    let accessToken = valueJSON["access_token"].string,
                    let refreshToken = valueJSON["refresh_token"].string
                else {
                    self.webViewController?.dismiss(animated: true, completion: nil)
                    return
                }
            
                self.OAuthAccessToken = accessToken
                self.OAuthRefreshToken = refreshToken
            
                self.keychain.set(accessToken, forKey: self.keychainAccessKey)
                self.keychain.set(refreshToken, forKey: self.keychainRefreshKey)
            
                self.setupAPIData()
                self.webViewController?.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }.resume()
    }
    
    /**
     Attempts to refresh the user's tokens with `OAuthRefreshToken`
     
     Removes current access token from keychain and if there is no refresh token,
     retries the OAuth login. Otherwise calls the API to received a new
     access token and store it in the keychain.
     
     - Parameter completionHandler: Called with `true` on success or `false` on failure.
     */
    func refreshOAuthToken(completionHandler: @escaping ((Bool) -> Void)) {
        keychain.delete(keychainAccessKey)
        
        guard let refreshToken = OAuthRefreshToken else {
            startOAuth2Login()
            return
        }
        print("Refreshing token with: \(refreshToken)")
        
        let url = URL(string: "https://api.intra.42.fr/oauth/token")!
        let tokenParams = [
            "grant_type": "refresh_token",
            "client_id": clientId,
            "client_secret": clientSecret,
            "refresh_token": refreshToken,
            "redirect_uri": redirectURI,
            "state": state
        ]
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = tokenParams.percentEscaped().data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                guard error == nil, let data = data, let valueJSON = try? JSON(data: data) else {
                    if let error = error {
                        print("Token Refresh Response Error: \(error)")
                    }
                    completionHandler(false)
                    return
                }
                
                guard valueJSON["token_type"].string == "bearer" else {
                    print("ERROR: token is not bearer")
                    completionHandler(false)
                    return
                }
                
                guard
                    let accessToken = valueJSON["access_token"].string,
                    let refreshToken = valueJSON["refresh_token"].string
                    else {
                        print("ERROR: couldn't find token")
                        completionHandler(false)
                        return
                }
                
                self.OAuthAccessToken = accessToken
                self.OAuthRefreshToken = refreshToken
                
                self.keychain.set(accessToken, forKey: self.keychainAccessKey)
                self.keychain.set(refreshToken, forKey: self.keychainRefreshKey)
                
                completionHandler(true)
            }
        }.resume()
    }
}
