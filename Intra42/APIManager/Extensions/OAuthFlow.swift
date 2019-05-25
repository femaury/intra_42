//
//  OAuthFlow.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

extension API42Manager {
    func startOAuth2Login() {
        let authPath = "https://api.intra.42.fr/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectURI)&state=\(state)&response_type=code"
        
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
            "client_id": clientId,
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
            "client_id": clientId,
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
