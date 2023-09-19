//
//  SplashView.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation


import SwiftUI

struct SplashView: View {
    @Binding public var isSplashView: Bool

    @State private var isRotating = 0.0
    @State private var isSettings: Bool = false
    var completionHandler: () -> Void

    var body: some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                if isSettings {
                    SettingsView() { 
                        withAnimation(.linear(duration: 0.5)) {
                            isSettings.toggle()
                        }
                        withAnimation {
                            self.isSplashView = false
                        }
                        completionHandler()
                    }
                } else {
                    Configuration.splashViewColor.ignoresSafeArea(.all)
                    VStack {
                        if Configuration.splashLogoDummy {
                            Image(systemName: "gear")
                                .foregroundColor(Color(.lightGray))
                                .font(.system(size: 64))
                                .rotationEffect(.degrees(isRotating))
                                .onAppear {
                                    withAnimation(.linear(duration: 1)
                                        .speed(0.1).repeatForever(autoreverses: false)) {
                                            isRotating = 360.0
                                        }
                                }
                        } else {
                            Image(Configuration.splashLogoIconName)
                                .withSplashViewStyles()
                            
                            // FIXME: remove
                            Image(systemName: "gear")
                                .foregroundColor(Color(.lightGray))
                                .font(.system(size: 32))
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.5)) {
                                        isSettings.toggle()
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                    .padding(.all)
                }
            }
            
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(Configuration.splashViewSeconds)) {
                if !isSettings {
                    withAnimation {
                        self.isSplashView = false
                    }
                }
            }
        }
    }

}
