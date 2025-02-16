//
//  AppView.swift
//  MovieDate
//
//  Created by Darina Baneva on 7.02.25.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        if let user = auth.user {
            if user.setupDone {
                ContentView()
            } else {
                // UserSetupView()
            }
        } else {
            NavigationStack {
                SignInView()
            }
        }
    }
}

#Preview {
    AppView()
        .environmentObject(AuthService.preview)
}
