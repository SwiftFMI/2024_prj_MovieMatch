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
        if auth.user == nil {
            NavigationStack {
                SignInView()
            }
        } else {
            ContentView()
        }
    }
}

#Preview {
    AppView()
        .environmentObject(AuthService.preview)
}
