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
        if !auth.loaded {
            ZStack {
                Style.appGradient
                ProgressView().colorScheme(.dark)
            }
        } else if let user = auth.user {
            if !user.personalizeDone {
                NavigationStack {
                    PersonalizeView()
                }
            } else if auth.mutualPartner == nil {
                PartnerJoinView()
            } else {
                NavigationStack {
                    MovieSwipeView()
                }
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
