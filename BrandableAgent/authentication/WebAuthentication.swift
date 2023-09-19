//
//  WebAuth.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation
import AuthenticationServices

/**
 * Provides an OAuth 2 authorization method
 */
class WebAuthentication: NSObject,ASWebAuthenticationPresentationContextProviding {
    
    private var webAuthSession: ASWebAuthenticationSession?
    
    private var oauthcode: String?
    private var oauthstate: String?

    private var accessToken: String?
    private var refreshToken: String?
    private var expiresIn: Double = 0
    private var refreshExpiresIn: Double = 0
    private var stopRefresh = false
    private var startedRefresh = false
    private var lastRefresh: Double = 0
    
    var session: LoginSession?
    
    
    override init() {
        super.init()
    }
    
    func clearTokensIfExist() {
        accessToken = nil
        refreshToken = nil
        expiresIn = 0
        refreshExpiresIn = 0
    }
    
    func getAccessToken() -> String? {
        return accessToken
    }

    func start(_ completionHandler: @escaping (Bool)-> Void) {
        
        guard let provider =  Configuration.authProvider else {
            return
        }
        
        clearTokensIfExist()
        
        webAuthSession = ASWebAuthenticationSession.init(url: provider.getTokenCodeUrl()!,callbackURLScheme: provider.webAuthCallbackURLScheme,completionHandler: { (callback:URL?, error:Error?) in
                guard error == nil, let successURL = callback else {
                    /// authorization canceled
                    completionHandler(false)
                    return
                }
                let oauthToken = URLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "code"}).first
                    
                guard oauthToken != nil else  {
                    /// back before authorization
                    completionHandler(false)
                    return
                }
                completionHandler(true)

                let authorizationCode = oauthToken?.value ?? ""
                print("\(authorizationCode)")
            
                var linkString = URLComponents(string: successURL.absoluteString)

                var parameters = [String: String]()
                for item in (linkString?.queryItems)! {
                   parameters[item.name] = item.value
                }
                self.oauthcode = parameters["code"]
                self.oauthstate = parameters["session_state"]
            
                self.getRefreshAccessToken()

        })
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.prefersEphemeralWebBrowserSession = true
        webAuthSession?.start()

    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

    func stopRefreshThread() {
        stopRefresh = true
    }

    /// get token by token id or refresh token
    func getRefreshAccessToken(_ refreshToken: String? = nil) {
        
        guard let provider =  Configuration.authProvider else {
            return
        }
        
        guard oauthcode != nil, oauthstate != nil else {
            return
        }
           
        let  arguments = provider.getTokenArguments(refreshToken,oauthcode,oauthstate)
        
        guard let requestUrl = provider.getTokenUrl() else {
            return
        }
        
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = "POST"
        request.httpBody = arguments.data(using: String.Encoding.utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                        self.clearTokensIfExist()
                        return
                }
                do {
                        print(String(data: data, encoding: String.Encoding.utf8))
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: [])  as? [String: Any] else {
                            self.clearTokensIfExist()
                            return
                        }
                        guard let access_token = json["access_token"] as? String else {
                            self.clearTokensIfExist()
                            return
                        }
                        guard let refresh_token = json["refresh_token"] as? String else {
                            self.clearTokensIfExist()
                            return
                        }
                        guard let expires_in = json["expires_in"] as? Int64 else {
                            self.clearTokensIfExist()
                            return
                        }
                        guard let refresh_expires_in = json[provider.type == .Microsoft ? "ext_expires_in" : "refresh_expires_in"] as? Int64 else {
                            self.clearTokensIfExist()
                            return
                        }
                        self.accessToken = access_token
                        self.refreshToken = refresh_token
                        self.expiresIn = Double(expires_in) ?? 0
                        self.refreshExpiresIn = Double(refresh_expires_in) ?? 0
                        self.lastRefresh = Date().timeIntervalSince1970
                        
                        if !self.startedRefresh {
                            self.startRefreshThread()
                        }
                    
                        print(self.accessToken)
                        
                        if let token =  self.accessToken, refreshToken != nil {
                            AppDelegate.updateTokenInServiceWorker(token)
                        }
                        if refreshToken == nil {
                            AppDelegate.createAndStartAgentClient([],self.accessToken) {
                                self.session?.state = .authenticated
                            }
                        }
                   } catch _ {
                   }
           }.resume()
       }
    
    
    func logout() {
        
        guard let provider =  Configuration.authProvider else {
            return
        }
        
        guard refreshToken != nil else {
            return
        }
           
       
        guard let requestUrl = provider.getLogoutUrl() else {
            return
        }
        
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = "POST"
        request.httpBody = provider.getLogoutArguments().data(using: String.Encoding.utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                        return
                }
                do {
                        print(String(data: data, encoding: String.Encoding.utf8))
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: [])  as? [String: Any] else {
                            return
                        }
                    
                    self.clearTokensIfExist()


                   } catch _ {
                   }
           }.resume()
    }
    
    /// this thread refreshes the token
    func startRefreshThread() {
        DispatchQueue.global(qos: .background).async {
            self.startedRefresh  = true
            while (!self.stopRefresh) {
                let delta = Date().timeIntervalSince1970 - self.lastRefresh
                if delta >= self.expiresIn - 120 && self.refreshToken?.count ?? 0 > 0 {
                    self.getRefreshAccessToken(self.refreshToken)
                } else if self.refreshToken == nil {
                    /// session expired
                    AppDelegate.setOAuthState(false)
                    return
                }
                sleep(15)
            }
        }
    }
    
    private func newCookie(domain: String, name: String, value: String? = nil) -> HTTPCookie? {
        var httpProperties: [HTTPCookiePropertyKey: Any] = [.domain: domain,.name: name, .value: value]
        return HTTPCookie(properties: httpProperties)
    }
}
