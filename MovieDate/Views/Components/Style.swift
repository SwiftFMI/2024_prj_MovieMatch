//
//  Style.swift
//  MovieDate
//
//  Created by Darina Baneva on 7.02.25.
//

import SwiftUI

struct AppGradient: View {
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [Color(red: 0, green: 0, blue: 0.5),
                                        Color(red: 0.5, green: 0, blue: 0)]),
            center: .topLeading,
            startRadius: 60,
            endRadius: 800)
        .ignoresSafeArea()
    }
}

struct AppTextFieldBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        colorScheme == .light ? Color.white.opacity(0.7) : Color.white.opacity(0.2)
    }
}

