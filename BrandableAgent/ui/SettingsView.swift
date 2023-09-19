//
//  Settings.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation
import SwiftUI



// FIXME: remove  
struct SettingsView: View {
    
    @State private var serverUrl: String = Configuration.unbluServerUrl
    @State private var serverEntryPath: String = Configuration.unbluServerEntryPath
    @State private var serverApiKey: String = Configuration.unbluApiKey
    @State private var selectedType: LoginSession.AutenticationType = .direct
    @State private var prevType:  LoginSession.AutenticationType = .direct

    var completed: () -> Void
    
    init(_ completed: @escaping ()->Void) {
        self.completed = completed
    }

    var body: some View {
        ZStack {
            
            Configuration.loginViewColor.ignoresSafeArea(.all)
            
            VStack {
                
                Text("Settings")
                    .foregroundColor(Configuration.loginViewTextColor)
                    .font(.title2)
                
                Spacer()
                    .frame(height:50)
                    .fixedSize()
                
                TextField("Server URL", text: $serverUrl)
                    .withLoginInputStyles()
                
                TextField("entry Path", text: $serverEntryPath)
                    .withLoginInputStyles()
                
                TextField("API Key", text: $serverApiKey)
                    .withLoginInputStyles()
                
                VStack {
                    Picker("Type", selection: $selectedType) {
                        Text("Direct").tag(LoginSession.AutenticationType.direct)
                        Text("Reverse Proxy").tag(LoginSession.AutenticationType.oauthProxy)
                        Text("Service Worker").tag(LoginSession.AutenticationType.oauth)
                    }.onChange(of: selectedType) { tag in
                        saveCurrentSettings()
                        prevType = tag
                        if !loadSavedSettings(tag) {
                            switch(tag) {
                            case .direct: setParamaters(server: "https://testing7.dev.unblu-test.com",entryPath: "/co-unblu", apiKey: "MZsy5sFESYqU7MawXZgR_w")
                            case .oauthProxy: setParamaters(server: "https://agent-sso-trusted.cloud.unblu-env.com",entryPath: "/app", apiKey: "IzkRDlr6QtKIZ7tQBfz5sw")
                            case .oauth: setParamaters(server: "https://brandable-agent-mobile-app.uenv.dev",entryPath: "/co-unblu", apiKey: "MZsy5sFESYqU7MawXZgR_w")
                            }
                        }
                    }
                }
                .pickerStyle(.segmented)
                
                Button("Done") {
                    saveCurrentSettings()
                    completed()
                }
                .withLoginButtonStyles()
                
            }
            .frame(maxWidth: 320)
            .padding(.horizontal)
        }.onAppear {
            loadSavedSettings(.direct)
        }
        
    }
    
    func saveCurrentSettings() {
        UserDefaults.standard.set(serverUrl,forKey: "serverUrl_"+prevType.rawValue)
        UserDefaults.standard.set(serverEntryPath,forKey: "serverEntryPath_"+prevType.rawValue)
        UserDefaults.standard.set(serverApiKey,forKey: "apiKey_"+prevType.rawValue)
    }
    
    func setParamaters(server: String,entryPath: String,apiKey: String) {
        Configuration.unbluServerUrl = server
        Configuration.unbluServerEntryPath = entryPath
        Configuration.unbluApiKey = apiKey
        Configuration.authType =  selectedType

        serverUrl = Configuration.unbluServerUrl
        serverEntryPath = Configuration.unbluServerEntryPath
        serverApiKey = Configuration.unbluApiKey
        
        AppDelegate.updateConfiguration()

    }
    
    private func loadSavedSettings(_ tag:LoginSession.AutenticationType) ->Bool {
        if let server = UserDefaults.standard.string(forKey: "serverUrl_"+tag.rawValue),
           let entryPath = UserDefaults.standard.string(forKey: "serverEntryPath_"+tag.rawValue),
            let key = UserDefaults.standard.string(forKey: "apiKey_"+tag.rawValue) {
            
            Configuration.unbluServerUrl = server
            Configuration.unbluServerEntryPath = entryPath
            Configuration.unbluApiKey = key
            Configuration.authType = tag
            
            selectedType = tag
            serverUrl = Configuration.unbluServerUrl
            serverEntryPath = Configuration.unbluServerEntryPath
            serverApiKey = Configuration.unbluApiKey
            
            AppDelegate.updateConfiguration()

            return true
        }
        return false
    }
}


