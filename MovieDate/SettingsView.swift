//
//  SettingsView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()

            VStack {
                if let user = auth.user {
                    Text("Hello, \(user.name)")
                        .foregroundStyle(.white)
                }

                Button(action: {
                    try? auth.signOut()
                }) {
                    Text("Sign Out")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService.preview)
}
