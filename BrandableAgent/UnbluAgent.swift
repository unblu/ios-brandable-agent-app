//
//  Agent.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation
import UnbluCoreSDK
import UnbluFirebaseNotificationModule
import UnbluMobileCoBrowsingModule
import FirebaseMessaging

// This class saves important states and
// helps to update the user interface when states change
class UnbluUiState : ObservableObject {
    ///shows whether we are in a ooverview or inside a conversation
    @Published var isOverview: Bool = true
    ///OAuth 2 authorization procedure was successfully completed
    @Published var oauthCompleted: Bool = false
    ///logout has occurred or the session has expired
    @Published var sessionEnded: Bool = false
    @Published var unbluView: UIView?
}

/**
 * It is an helper that creates and maintains instances of unblu
 */
class UnbluAgent {
    
    var callModule: UnbluCallModuleApi?
    var unbluAgentClient: UnbluAgentClient?
    var userNotificationCenter = NotificationCenterDelegate()
    var firebaseDelegate: FirebaseDelegate?
    
    var unbluConfiguration:UnbluClientConfiguration?
    var agentDelegate: AgentClientDelegate?
    
    var unbluUiState = UnbluUiState()
    
    var coBrowsingModule:UnbluMobileCoBrowsingModuleApi?
    
    func createAgentConfiguration(_ token: String? = nil) {
        // Set Icon for CallKit UI
        UnbluClientConfiguration.callKitProviderIconResourceName = Configuration.callKitIcon

        //1. Register modules
        unbluConfiguration = createUnbluConfig()
        unbluConfiguration?.ouathToken = token
        unbluConfiguration?.unbluPushNotificationVersion = .EncryptedService
        /// by default, all URLs are allowed, you can change this by adding only the URL of your unblu server instance or reverse proxy server
        /// for example "^https://testing7.dev.unblu-test.com*$"
        /// in the case of authorization via a reverse proxy server, in addition to the reverse proxy server, the web address of the identity card provider should be added
        unbluConfiguration?.internalUrlPatternWhitelist = [ try! NSRegularExpression(pattern: "^.*$", options: []) ]
        
        if !Configuration.clientCertBasedAuthentication.pkcs12FileName.isEmpty &&
            !Configuration.clientCertBasedAuthentication.pkcs12Password.isEmpty {
            unbluConfiguration?.authenticationChallengeDelegate = ClientAuthenticationChallengeDelegate()
        }
        
        callModule = UnbluCallModuleProvider.create()
        try! unbluConfiguration?.register(module: callModule!)
        callModule?.delegate = CallModuleDelegate()
        
        let config = UnbluMobileCoBrowsingModuleConfiguration(privateViews: [])
        coBrowsingModule = UnbluMobileCoBrowsingModuleProvider.create(config: config)
        try! unbluConfiguration?.register(module: self.coBrowsingModule!)

        //2 Set NotificationCenter delegate
        UNUserNotificationCenter.current().delegate = userNotificationCenter
 
        //4. Init Firebase , register for Push notifications
        firebaseDelegate = FirebaseDelegate()

    }
    
    
    func createAgentClient(_ cookies: [HTTPCookie]) -> Bool {
        unbluConfiguration?.customCookies = Set(cookies.map { UnbluCookie(name: $0.name, value: $0.value, expiryDate: $0.expiresDate) })
        return createAgentClient()
    }
    
    func createAgentClient() -> Bool {
        if let config = unbluConfiguration {
            //3. Create client , register for PushKit notifications
            unbluAgentClient = Unblu.createAgentClient(withConfiguration: config)
            unbluAgentClient?.logLevel = .verbose
            unbluAgentClient?.enableDebugOutput = true
            
            agentDelegate = AgentClientDelegate(self)
            unbluAgentClient?.agentDelegate = agentDelegate
            DispatchQueue.main.async {
                self.unbluUiState.unbluView = self.unbluAgentClient?.view
            }
            return true
        }
        return false
    }
    
    func updateOAuthToken(_ newToken: String) {
        unbluAgentClient?.setOAuthToken(token: newToken)
    }

    
    
    func createUnbluConfig() -> UnbluClientConfiguration {
        var configuration = UnbluClientConfiguration(unbluBaseUrl: Configuration.unbluServerUrl,
                                                     apiKey:  Configuration.unbluApiKey,
                                                     preferencesStorage: UserDefaultsPreferencesStorage(),
                                                     fileDownloadHandler: UnbluDefaultFileDownloadHandler(),
                                                     externalLinkHandler: UnbluDefaultExternalLinkHandler())
        configuration.entryPath = Configuration.unbluServerEntryPath
        return configuration
    }

    
    func startConnection(completionHandler: @escaping (Bool, Bool) -> Void) {
        if let client = unbluAgentClient {
            client.isInitialized(success: { isInitialized in
                if !isInitialized {
                    // Send APNs PushKit token and FCM token to the Unblu server
                    self.unbluAgentClient?.start { result in
                        switch result {
                        case .success:
                            completionHandler(true,true)
                        case .failure(let error):
                            completionHandler(false,true)
                        }
                    }
                }
            })
        } else {
            completionHandler(false,false)
        }
    }
    
    func stop(completionHandler: @escaping () -> Void) {
        self.unbluAgentClient?.stop { result in
            completionHandler()
        }
    }
    
}



class ClientAuthenticationChallengeDelegate: AuthenticationChallengeDelegate {
    let challengeHandler = UnbluAuthenticationChallengeHandler(pkcs12FileName: Configuration.clientCertBasedAuthentication.pkcs12FileName, 
                                                               pkcs12Password: Configuration.clientCertBasedAuthentication.pkcs12Password)

    func didReceive(authenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        challengeHandler.didReceive(authenticationChallenge: challenge, completionHandler: completionHandler)
    }
    
}

