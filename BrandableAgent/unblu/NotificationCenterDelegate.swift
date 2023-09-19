//
//  NotificationCenterDelegate.swift
//

import Foundation
import UnbluCoreSDK

/// handles incoming push notifications when the app is in background and if a user tabs on them
 class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    

    // process the response (tap on it) to a notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        do {
            try UnbluNotificationApi.instance.didReceive(notificationResponse: response, withCompletionHandler: completionHandler)
        } catch {
            print("not unblu notification")
            completionHandler()
        }
    }
    
     // the app is running in the foreground
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        do {
            try UnbluNotificationApi.instance.willPresent(notification: notification, withCompletionHandler: completionHandler)
        } catch {
            print("not unblu notification")
            completionHandler([.alert, .badge, .sound])
        }
    }
}
