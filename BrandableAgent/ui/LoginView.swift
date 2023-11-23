//
//  LoginView.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation
import SwiftUI




struct LoginView: View {
    @EnvironmentObject var loginSession: DirectLoginSession
    
    @State private var userName: String = "superadmin"
    @State private var password: String = "superadmin" 

    @State private var isAuthenticating: Bool = false
    private let isAuthenticatingTitle = "Logging in"
    @State private var isSecured: Bool = true
    var completionHandler: (Bool, Bool) -> Void

    private var isLoginDisabled: Bool {
        (loginSession.state == .isAuthenticating) || userName.isEmpty || password.isEmpty

    }

    var body: some View {
        ZStack {
            
            Configuration.loginViewColor.ignoresSafeArea(.all)
            HStack(alignment: .top) {
                ZStack(alignment: .topLeading) {
                        VStack(spacing: 40) {
                            VStack(alignment: .center) {
                                Image("logo_o")
                                Text(Configuration.loginTitle)
                                    .withLoginTitleStyles()
                            }
                            VStack(spacing: 20) {
                                VStack(alignment: .leading) {
                                    Text("Username")
                                        .withLoginLabelStyles()
                                    TextField(Configuration.usernameLabel, text: $userName)
                                        .withLoginInputStyles()
                                }
                                VStack(alignment: .leading) {
                                    Text("Password")
                                        .withLoginLabelStyles()
                                    ZStack(alignment: .trailing) {
                                        if isSecured {
                                            SecureField(Configuration.passwordLabel, text: $password)
                                                .withLoginInputStyles()
                                        } else {
                                               TextField("", text: $password)
                                                .withLoginInputStyles()
                                        }
                                        Button(action: {
                                            isSecured.toggle()
                                        }) {
                                            Image(systemName: self.isSecured ? "eye.slash" : "eye")
                                                .accentColor(.gray)
                                        }
                                    }
                                }
                            }
                            ZStack(alignment: .center) {
                                Button(action: {
                                    isAuthenticating = true
                                    self.login()
                                }) {
                                    HStack {
                                        if isAuthenticating {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                        }
                                      Text(isAuthenticating ?  isAuthenticatingTitle : Configuration.loginButtonLabel)
                                            .contentShape(Rectangle())

                                    }.frame(maxWidth: .infinity)
                                }
                                .withLoginButtonStyles()
                                .disabled(isLoginDisabled)
                              
                            }
                            
                        }
                        .frame(maxWidth: 320)
                        .padding(.horizontal)
                }
            }
        }
    }
        
    private func login() {
        loginSession.directLogin(username: userName, password: password) { cookies,result in
               isAuthenticating = false
               switch (result) {
                    case .success():
                            if let cookies = cookies, AppDelegate.createAgentClient(cookies) {
                                AppDelegate.connectToUnbluServer(completionHandler: completionHandler)
                            }
                    case .failure(_):
                            completionHandler(false,true)
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {  
  static var previews: some View {
          LoginView(){_,_ in
              
          }
          .environment(\.locale, .init(identifier: "en"))
          .previewLayout(.sizeThatFits)
          .environmentObject(DirectLoginSession(.direct))
      }
}
