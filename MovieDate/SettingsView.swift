//
//  SettingsView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authSvc: AuthService
    @EnvironmentObject private var userSvc: UserService

    var body: some View {
        ZStack {
            Style.appGradient

            VStack {
                if let user = userSvc.user {
                    Text("Hello, \(user.name)")
                        .foregroundStyle(.white)
                }

                Button(action: {
                    try? authSvc.signOut()
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
        .environmentObject(PreviewCompose.authSvc)
        .environmentObject(PreviewCompose.userSvc)
}
