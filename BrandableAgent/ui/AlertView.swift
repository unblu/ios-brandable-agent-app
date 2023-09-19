//
//  AlertView.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//


import Foundation
import SwiftUI

struct AlertView: View {
    var title: String
    var completionHandler: () -> Void
    
    var body: some View {
        ZStack {
            
            Configuration.loginViewColor.ignoresSafeArea(.all)
            
            VStack {
                
                Text(title)
                    .foregroundColor(Configuration.loginViewTextColor)
                    .font(.title2)
                Spacer()
                    .frame(height:50)
                    .fixedSize()
                
                Button(action: {
                    self.completionHandler()
                }) {
                    HStack {
                      Text("Ok")
                            .contentShape(Rectangle())
                    }.frame(maxWidth: .infinity)
                }
                .withLoginButtonStyles()
            }
            .frame(maxWidth: 320)
            .padding(.horizontal)
        }
        
    }

}


