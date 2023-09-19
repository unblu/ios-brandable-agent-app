//
//  AppDelegate.swift
//

import Foundation
import UIKit
import FirebaseMessaging
import UnbluFirebaseNotificationModule
import WebKit


class AppDelegate: UIResponder, UIApplicationDelegate {

    static private(set) var instance: AppDelegate! = nil
    let unbluAgent = UnbluAgent()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.instance = self
        unbluAgent.createAgentConfiguration()
        if Configuration.notificationsMode == .APNsUserNotifications {
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            unbluAgent.firebaseDelegate?.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }
     
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if Configuration.notificationsMode == .APNsUserNotifications {
            let token = deviceToken.map { String(format: "%02x", $0) }.joined()
            UnbluNotificationApi.instance.deviceToken = token;
        } else {
            Messaging.messaging().apnsToken = deviceToken;
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        do {
            try UnbluNotificationApi.instance.handleRemoteNotification(userInfo: userInfo,withCompletionHandler: {_ in
            })
        } catch {
            unbluAgent.firebaseDelegate?.on_application(application, didReceiveRemoteNotification: userInfo)
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        do {

            try UnbluNotificationApi.instance.handleRemoteNotification(userInfo: userInfo,withCompletionHandler: {_ in
            })
        } catch {
            unbluAgent.firebaseDelegate?.on_application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        }
    }
}


extension AppDelegate {
    
    /// create  Unblu client agent
    static func createAgentClient(_ cookies: [HTTPCookie]) -> Bool {
        return instance.unbluAgent.createAgentClient(cookies)
    }
    
    /// start interacting with the unblu server
    static func connectToUnbluServer(completionHandler: @escaping (Bool,Bool) -> Void) {
        instance.unbluAgent.startConnection(completionHandler: completionHandler)
    }
    
    static func createAndStartAgentClient(_ newCookies: [HTTPCookie]?,_ token: String?,completed: @escaping ()->Void) {
        if token != nil {
            instance.unbluAgent.createAgentConfiguration(token)
        }
        if let cookies = newCookies, AppDelegate.createAgentClient(cookies) {
            connectToUnbluServer(completionHandler: { isOk,isDirect in
                setOAuthState(isOk)
                completed()
            })
        }
    }

    /// stops the current unbluAgentClient and will create a new instance
    static func logout(){
        instance.unbluAgent.unbluUiState.unbluView?.isHidden = true
        instance.unbluAgent.stop() {
        }
    }
    
    static func setOAuthState(_ state: Bool) {
        /// update published value
        instance.unbluAgent.unbluUiState.oauthCompleted = state
        if !state {
            instance.unbluAgent.unbluUiState.sessionEnded = true
        }
    }
    
    static func getUnbluUiState() -> UnbluUiState {
        /// return ObservableObject
        return instance.unbluAgent.unbluUiState
    }
    
    static func updateConfiguration() {
        instance.unbluAgent.createAgentConfiguration()
    }
    
    static func updateTokenInServiceWorker(_ token: String) {
        instance.unbluAgent.unbluAgentClient?.setOAuthToken(token: token)
    }
    
    static func clearAllCookies() {
        let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
                for record in records {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
                    })
                }
            }
    }
}


