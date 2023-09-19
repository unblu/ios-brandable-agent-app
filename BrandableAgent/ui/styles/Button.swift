//
//  ButtonStyles.swift
//  BrandableAgent
//
//  Created by Denis Mikaya on 17.03.23.
//

import Foundation
import SwiftUI

extension Button {
    func withLoginButtonStyles() -> some View {
        self.foregroundColor(.white)
            .font(Font.body.bold())
            .padding(10)
            .padding(.horizontal,20)
            .frame(maxWidth: .infinity)
            .background(Color(red: 250/255, green: 96/255, blue: 25/255))
                    .cornerRadius(4)
    }
}
