//
//  Text.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation
import SwiftUI

extension Text {
    func withLoginTitleStyles() -> some View {
        return self.foregroundColor(Configuration.loginViewTextColor)
            .font(.subheadline)
    }
    
    func withLoginLabelStyles() -> some View {
        return self.foregroundColor(Configuration.loginViewTextColor)
            .font(.body)
    }
}
