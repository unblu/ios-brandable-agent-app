//
//  WebProxyAuthentication.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 28.03.23.
//

import Foundation
import WebKit
import UIKit
import SwiftUI

/**
 *This delegation class is designed to catch the moment of successful authorization with the help of a reverse proxy server.
 *This moment  when a redirect occurs to the initial entry point of unblu
 */
class WebViewNavigationDelegate: NSObject,WKNavigationDelegate {
    
    enum State {
        case none
        case started
        case finished
    }
    
    let authWebView: RepresentedWebView
    var currentState: State = .none
    
    init (_ webView: RepresentedWebView) {
        authWebView = webView
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString {
            let success = url.contains(Configuration.unbluServerUrl+Configuration.unbluServerEntryPath+"/desk") ? true : false
            if success {
                webView.stopLoading()
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    self.authWebView.complete(cookies,nil)
                }
            }
        }
    }
    
}

/**
 * Provides an authorization method using a reverse proxy server
 * After authentication is complete, this view should be replaced by Unblu View
 */
struct WebProxyAuthentication: View {
    @State private var isLoaded: Bool = false
    var complete: ([HTTPCookie]?,String?) ->Void
    
    var body: some View {
        VStack {
            RepresentedWebView(complete)
                .padding()
        }
        .padding()
    }
}



struct RepresentedWebView: UIViewRepresentable {
    typealias UIViewType = UIView
    var webView: WKWebView
    var complete: ([HTTPCookie]?,String?) ->Void

    var webViewConfiguration: WKWebViewConfiguration
    var navigationDelegate: WebViewNavigationDelegate?
    
    init(_ complete: @escaping ([HTTPCookie]?,String?) ->Void) {
        self.complete = complete
        webViewConfiguration =  WKWebViewConfiguration()
        webViewConfiguration.limitsNavigationsToAppBoundDomains = true
        webView = WKWebView(frame: CGRect(x: 0,y: 0,width: 400,height: 800), configuration: webViewConfiguration)
        //webViewConfiguration.websiteDataStore = .nonPersistent()
        navigationDelegate = WebViewNavigationDelegate(self)
        webView.navigationDelegate = navigationDelegate
        load()
    }
    
    func makeUIView(context: Context) -> UIView {
        return webView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func load()  {
        let req = URLRequest(url: URL(string: Configuration.webAuthProxyServerAddress)!,cachePolicy: .reloadIgnoringLocalCacheData)
        webView.load(req)
    }
}
