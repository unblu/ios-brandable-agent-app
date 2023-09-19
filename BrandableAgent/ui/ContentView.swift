//
//  ContentView.swift
//

import SwiftUI
import UIKit
import Combine

struct ContentView: View {
    @EnvironmentObject var loginSession: DirectLoginSession
    @EnvironmentObject var unbluState: UnbluUiState
    @State private var showLoginView: Bool = true
    @State private var isAutenticationAlert: Bool = false
    @State private var forceAuthentication: Bool = false

    init(_ showLoginView: Bool) {
        _showLoginView = State(initialValue: showLoginView)
    }

    var body: some View {
        
        HStack {
            if unbluState.sessionEnded {
                AlertView(title: Configuration.sessionExpired) {
                    showLoginView =  loginSession.type == .direct || loginSession.type == .oauthProxy ? true : false
                    loginSession.state = .needsAuthentication
                    unbluState.sessionEnded = false
                    unbluState.isOverview = true
                    self.restartAuthentication()
                }
            } else
            if (loginSession.type == .oauth || loginSession.type == .oauthProxy) && loginSession.state != .authenticated {
                ZStack{
                    ProgressView {
                        Text("Loading...")
                            .font(.title2)
                    }
                }.frame(width: 120, height: 120, alignment: .center)
            } else
            if !showLoginView && loginSession.state == .authenticated {
                VStack(alignment: .center) {
                    if let view = unbluState.unbluView {
                        ZStack(alignment: .topTrailing) {
                            RepresentedUnbluView(view)
                                .padding(EdgeInsets(top: 0,leading: 0,bottom: 0,trailing: 0))
                            if unbluState.isOverview && Configuration.logoutIcon {
                                Button {
                                    showLoginView =  loginSession.type == .direct ? true : false
                                    loginSession.state = .needsAuthentication
                                    self.restartAuthentication()
                                } label: {
                                    HStack {
                                        Image(systemName:  Configuration.logoutIconSystemName)
                                            .foregroundColor(Color(.white))
                                            .imageScale(.large)
                                            .clipShape(Rectangle())
                                    }.padding(EdgeInsets(top: 0,leading: 10,bottom: 0,trailing: 10))
                                }.offset(x: -Configuration.logoutIconOffest,y: Configuration.logoutIconOffest)
                            }
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onAppear() {
                    if unbluState.oauthCompleted {
                        unbluState.oauthCompleted = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showLoginView) {
            //FIXME: remove when settings
            if forceAuthentication {}
            if isAutenticationAlert {
                /// a direct authentication error occurred
                AlertView(title: Configuration.authenticationFailedLabel) {
                    isAutenticationAlert.toggle()
                }
            } else {
                // Authorization via direct login
                if loginSession.type == .direct {
                    LoginView() { isOk,isDirect in
                        if isOk {
                            showLoginView = false
                        } else if isDirect {
                            isAutenticationAlert.toggle()
                        } else {
                            loginSession.state = .needsAuthentication
                            loginSession.type = .oauthProxy
                            forceAuthentication.toggle()
                        }
                    }
                    .environmentObject(loginSession)
                } else if loginSession.type == .oauthProxy {
                    // Authentication through OAuth2 reverse proxy
                    WebProxyAuthentication() { cookies, error in
                        guard error == nil else {
                            isAutenticationAlert.toggle()
                            return
                        }
                        AppDelegate.createAndStartAgentClient(cookies,nil) {
                            loginSession.state = .authenticated
                        }
                        showLoginView = false
                    }
                }
            }
        }.onAppear {
            // OAuth2 Authentication through an external identity provider
            if loginSession.type == .oauth {
                loginSession.webAuth.session = loginSession
                loginSession.webAuth.start() { isAuth in
                    if !isAuth {
                        unbluState.sessionEnded = true
                    }
                }
            }
        }
    }
    
    func restartAuthentication() {
        /// stop the current session and create a new agent
        AppDelegate.logout()
        
        if loginSession.type == .oauth {
            // restart authentication
            unbluState.oauthCompleted = false
            loginSession.webAuth.logout()
            loginSession.webAuth.start() { isAuth in
                if !isAuth {
                    unbluState.sessionEnded = true
                }
            }
        } else   if loginSession.type == .oauthProxy {
            AppDelegate.clearAllCookies()
            unbluState.oauthCompleted = false
            loginSession.state = .needsAuthentication
            showLoginView = true
        } else if loginSession.type == .direct {
            
        }
    }

}


struct RepresentedUnbluView: UIViewRepresentable {
    typealias UIViewType = UIView
    let view: UIView
    
    init(_ view: UIView) {
        self.view = view
    }
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
