//
//  IdentityProvider.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 12.04.23.
//

import Foundation


enum IdentityProviderType {
    case None
    case Keycloak
    case Microsoft
}

/**
 * This class contains OAuth 2 settings and helps to generate URLs for sending requests to identity providers.
 */
struct IdentityProvider {
    
    let type:IdentityProviderType
    
    let webAuthServerAddress: String
    let webAuthBaseUrl: String
    
    let webAuthClientId: String
    let webAuthClientSecret: String
    let webAuthCallbackURLScheme: String
    
    let webAuthGetTokenId: String
    let webAuthGetToken: String
    let webAuthLogout: String
    
    var webAuthTenant: String?
    
    func getTokenCodeUrl() -> URL? {
        var url = webAuthServerAddress
        if let tenant = webAuthTenant, type == .Microsoft {
            url.append("/"+tenant)
        }
        url.append(webAuthBaseUrl)
        url.append(webAuthGetTokenId)
        if type == .Microsoft {
            url.append("&redirect_uri="+webAuthCallbackURLScheme+"%3A%2F%2Fauth")
            url.append("&scope=openid%20profile%20email")
        }
        url.append("&client_id="+webAuthClientId)
        return URL(string: url)
    }
    
    func getTokenUrl() ->URL? {
        var url = webAuthServerAddress
        if let tenant = webAuthTenant, type == .Microsoft {
            url.append("/"+tenant)
        }
        url.append(webAuthBaseUrl)
        url.append(webAuthGetToken)
        return URL(string: url)
    }
    
    func getTokenArguments(_ refreshToken: String? = nil,_ oauthCode : String? = nil,_ oauthState: String? = nil) ->String {
        var  arg = "client_id=" + webAuthClientId
        if refreshToken != nil {
            arg.append("&grant_type=refresh_token")
            arg.append("&refresh_token="+refreshToken!)
        } else {
            arg.append("&grant_type=authorization_code")
            if (type != .Microsoft) {
                arg.append("&state=" + (oauthState ?? ""))
                arg.append("&client_secret=" + webAuthClientSecret)
            }
            arg.append("&code=" + (oauthCode ?? ""))
        }
        if type == .Microsoft {
            arg.append("&scope=openid%20profile%20email%20offline_access")
            arg.append("&redirect_uri="+webAuthCallbackURLScheme+"%3A%2F%2Fauth")
        }
        print("")
        return arg
    }

    func getLogoutUrl() ->URL? {
        var url = webAuthServerAddress
        if let tenant = webAuthTenant, type == .Microsoft {
            url.append("/"+tenant)
        }
        url.append(webAuthBaseUrl)
        url.append(webAuthLogout)
        return URL(string: url)
    }
    
    func getLogoutArguments(_ refreshToken: String? = nil) ->String {
        var  arg = "client_id=" + webAuthClientId
        arg.append("&refresh_token="+(refreshToken ?? ""))
        return arg
    }
}

