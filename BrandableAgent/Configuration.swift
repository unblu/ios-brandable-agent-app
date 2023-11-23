//
//  Configuration.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation
import SwiftUI

class Configuration {
    // if this is APNsUserNotifications, we send user push notifications directly via APNS, otherwise via Firebase.
    static let notificationsMode : NotificationsMode = .FirebaseNotifications
    
    // Icons
    static let callKitIcon = "go-to-app"
    static let logoutIconSystemName = "rectangle.portrait.and.arrow.right"
    static let logoutIconOffest:CGFloat = 15
    static let logoutIcon = true

    // Login View
    static let usernameLabel = String(localized: "User name")
    static let passwordLabel = String(localized: "Password")
    static let loginButtonLabel = String(localized: "Log in")
    static let loginTitle = String(localized: "Please log in")
    static let authenticationFailedLabel = String(localized: "Authentication failed")
    static let sessionExpired = String(localized: "Authentication session expired")
    static let loginViewColor = Color.white
    static let loginViewTextColor = Color.black
    
    // Splash View
    static let splashView = true
    static let splashViewSeconds = 3
    static let splashViewColor = Color(red: 250/255, green: 96/255, blue: 25/255)
    static let splashLogoDummy = false
    static let splashLogoIconName = "logo2"
    
    static var unbluApiKey = "MZsy5sFESYqU7MawXZgR_w"

    static var unbluServerUrl = "https://testing7.dev.unblu-test.com"
    static var unbluServerEntryPath = "/co-unblu"

    static let webAuthProxyServerAddress =  "https://agent-sso-trusted.cloud.unblu-env.com"
    
    // Default authentication type
    static var authType: LoginSession.AutenticationType = .direct

    static let authProvider: IdentityProvider? = IdentityProvider(type: .Microsoft,webAuthServerAddress:  "https://login.microsoftonline.com",
                                                webAuthBaseUrl: "/oauth2/v2.0",
                                                webAuthClientId: "aae6ad6b-2230-414e-83f0-2b5933499b0b",
                                                webAuthClientSecret: "VJ38Q~r0i77qACoCtdN~dig9XsYPFrT-5mZadaef",
                                                webAuthCallbackURLScheme: "msauth.com.unblu.prototype.BrandableAgent",
                                                webAuthGetTokenId: "/authorize?response_type=code",
                                                webAuthGetToken: "/token",
                                                webAuthLogout: "/logout",
                                                webAuthTenant:"8005dd54-64b0-4f9d-bf46-e2582d0c2760")
    
    // Providing a digital certificate that can be verified by a server, for example: (pkcs12FileName: "client_cert", pkcs12Password: "secret")
    // You need to create a password-protected PKCS#12 file for certificates with the '.p12' extension
    // Then put this file in ios-brandable-agent-app/BrandableAgent/
    // The file name without path and extension, as well as the password, you must specify in the line below
    static let clientCertBasedAuthentication =  (pkcs12FileName: "", pkcs12Password: "")
    
}

enum NotificationsMode {
    case FirebaseNotifications
    case APNsUserNotifications
}
