//
//  TextField.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation
import SwiftUI


extension TextField {
    func withLoginInputStyles() -> some View {
        self.textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
    func backgroundRoundBorder() -> some View {
        self.autocapitalization(.none)
        .disableAutocorrection(true)
        .background(Color(UIColor.systemGray6))
        .clipShape(Capsule(style: .continuous))
    }
}
