//
//  UnbluDemoApp.swift
//

import SwiftUI



/**
 * The main entry point to the user interface of the application
 */
@main
struct BrandableAgentApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject var loginSession = DirectLoginSession(Configuration.authType)
    @StateObject var unbluState = AppDelegate.getUnbluUiState()
    @State private var isSplashView: Bool = Configuration.splashView

    var body: some Scene {
        WindowGroup {
            if isSplashView {
                SplashView(isSplashView: self.$isSplashView) {
                    /// FIXME: only if we have a setting panel
                    loginSession.type = Configuration.authType
                }
            } else {
                ContentView(loginSession.type == .direct || loginSession.type == .oauthProxy)
                    .environmentObject(loginSession)
                    .environmentObject(unbluState)

            }

        }
    }
}
