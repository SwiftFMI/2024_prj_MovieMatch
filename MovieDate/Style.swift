//
//  Style.swift
//  MovieDate
//
//  Created by Darina Baneva on 7.02.25.
//

import SwiftUI

struct Style {
    static var appGradient: some View {
        RadialGradient(
            gradient: Gradient(colors: [Color(red: 0, green: 0, blue: 0.5),
                                        Color(red: 0.5, green: 0, blue: 0)]),
            center: .topLeading,
            startRadius: 60,
            endRadius: 800)
        .ignoresSafeArea()
    }
}
