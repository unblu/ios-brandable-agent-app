//
//  LoginSession.swift
//  UnbluDemo
//
//  Created by Denis Mikaya on 16.03.23.
//

import Foundation
import AuthenticationServices
import UnbluCoreSDK
import SwiftUI


/**
 * Current authorization configuration and its status
 */
class LoginSession: NSObject,ObservableObject {
    enum AutenticationType: String, CaseIterable, Identifiable {
        case direct
        case oauth
        case oauthProxy
        var id: Self { self }
    }
    enum AutenticationState {
        case needsAuthentication
        case isAuthenticating
        case authenticated
    }
    var type: AutenticationType = .direct
    var state: AutenticationState = .needsAuthentication
    let webAuth = WebAuthentication()
}


/**
 *  Direct login authorization
 */
class DirectLoginSession: LoginSession {
    
    private struct LoginBody: Encodable {
        
        let username: String
        let password: String
        private let redirectOnSuccess: String?
        private let redirectOnFailure: String?
        
        init(username: String, password: String) {
            self.username = username
            self.password = password
            self.redirectOnSuccess = nil
            self.redirectOnFailure = nil
        }
        
        enum CodingKeys: String, CodingKey {
            case username
            case password
            case redirectOnSuccess
            case redirectOnFailure
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(username, forKey: .username)
            try container.encode(password, forKey: .password)
            try container.encode(redirectOnSuccess, forKey: .redirectOnSuccess)
            try container.encode(redirectOnFailure, forKey: .redirectOnFailure)
        }
    }
        
    init(_ type: AutenticationType) {
        super.init()
        self.type = type
    }
    
    func directLogin(username: String, password: String, completion: (([HTTPCookie]? ,Result<Void, UnbluClientInitializeError>) -> Void)? = nil) {
        
        self.state = .isAuthenticating
        
        
        guard let requestUrl = URLComponents(string: Configuration.unbluServerUrl + Configuration.unbluServerEntryPath+"/rest/v3/authenticator/login")?.url else {
            completion?(nil,.failure(.initFailed(errorType: .invalidUrl, details: "Unable to build authentication url")))
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(LoginBody(username: username, password: password))
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let currentTime = Date().timeIntervalSince1970

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.state = .needsAuthentication
                DispatchQueue.main.async { completion?(nil,.failure(.initFailed(errorType: .authentication, details: "\(error)"))) }
                return
            }
            guard let data = data, NSString(data: data, encoding: String.Encoding.utf8.rawValue)?.boolValue == true else {
                self.state = .needsAuthentication
                DispatchQueue.main.async { completion?(nil,.failure(.initFailed(errorType: .authentication, details: "Invalid login credentials"))) }
                return
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                self.state = .needsAuthentication
                DispatchQueue.main.async { completion?(nil,.failure(.initFailed(errorType: .authentication, details: "Invalid status code"))) }
                return
            }
            
            guard let fields = response.allHeaderFields as? [String: String], let url = response.url else {
                self.state = .needsAuthentication
                DispatchQueue.main.async { completion?(nil,.failure(.initFailed(errorType: .authentication, details: "Unable to get headers"))) }
                return
            }
            
            var cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
            cookies = cookies.filter { $0.expiresDate?.timeIntervalSince1970 ?? currentTime >= currentTime }

            self.state = .authenticated
            DispatchQueue.main.async { completion?(cookies,.success(())) }

            
        }.resume()
    }
    
   
}




