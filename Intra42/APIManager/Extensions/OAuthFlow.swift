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
import WebKit

extension API42Manager {
    /**
     Starts OAuth login flow
     
     If user already has a token, calls `oAuthTokenCompletionHandler` with `nil`.
     Otherwise opens 42's API OAuth page in safari to prompt user to login.
     */
    func startOAuth2Login() {
        if hasOAuthToken() {
            if let completionHandler = oAuthTokenCompletionHandler {
                completionHandler(nil)
            }
            return
        }
        
        state = generateRandomString()
        let authPath = "https://api.intra.42.fr/oauth/authorize?"
            + "client_id=\(clientId)&redirect_uri=\(redirectURI)"
            + "&state=\(state)&response_type=code&scope=public+profile+projects"
                
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
            self.webViewController = controller
            _ = controller.view
            controller.load(authPath)
            getTopViewController()?.present(controller, animated: true, completion: nil)
        }
    }
    
    fileprivate func generateRandomString() -> String {
        let length = Int.random(in: 43...128)
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    /**
     Processes OAuth's login response.
     
     Called by `AppDelegate` when `redirectURI` is called by 42's API.
     Verifies that the response is valid then calls the API to received the user's token.
     Stores the access and refresh tokens in the KeyChain, then gets all data about logged
     in user.
     
     If error, calls `oAuthTokenCompletionHandler` with `CustomError`.
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
                if let completionHandler = self.oAuthTokenCompletionHandler {
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
        
        let url = URL(string: oAuthURL)!
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
                    if let completionHandler = self.oAuthTokenCompletionHandler {
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
                
                self.oAuthAccessToken = accessToken
                self.oAuthRefreshToken = refreshToken
                
                self.setupAPIData()
                self.webViewController?.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }.resume()
    }
    
    /**
     Attempts to refresh the user's tokens with `oAuthRefreshToken`
     
     Removes current access token from keychain and if there is no refresh token,
     retries the OAuth login. Otherwise calls the API to received a new
     access token and store it in the keychain.
     
     - Parameter completionHandler: Called with `true` on success or `false` on failure.
     */
    func refreshOAuthToken(completionHandler: @escaping ((Bool) -> Void)) {
        keychain.delete(keychainAccessKey)
        
        guard let refreshToken = oAuthRefreshToken else {
            startOAuth2Login()
            return
        }
        print("Refreshing token with: \(refreshToken)")
        
        let url = URL(string: oAuthURL)!
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
                
                self.oAuthAccessToken = accessToken
                self.oAuthRefreshToken = refreshToken
                
                completionHandler(true)
            }
        }.resume()
    }
}
