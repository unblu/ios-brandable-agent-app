//
//  FirebaseDelegate.swift
//

import Foundation

import UnbluFirebaseNotificationModule

///default implementation for all notifications which are NOT for unblu
class FirebaseDelegate: UnbluFirebaseUIApplicationDelegate {
   
    override func on_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("not unblu remote notification")
    }

   
    override func on_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("not unblu remote notification")
    }
}
