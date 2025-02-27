//
//  AppView.swift
//  MovieDate
//
//  Created by Darina Baneva on 7.02.25.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject private var userSvc: UserService
    @EnvironmentObject private var userPartnerSvc: UserPartnerService

    var body: some View {
        if !(userSvc.loaded && userPartnerSvc.loaded) {
            ZStack {
                AppGradient()
                ProgressView().colorScheme(.dark)
            }
        } else if let user = userSvc.user {
            if !user.personalizeDone {
                NavigationStack {
                    PersonalizeView()
                }
            } else if userPartnerSvc.mutualPartner == nil {
                NavigationStack {
                    PartnerJoinView()
                }
            } else {
                NavigationStack {
                    HomeView()
                        .preferredColorScheme(.dark)
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
        .environmentObject(PreviewCompose.userSvc)
        .environmentObject(PreviewCompose.userPartnerSvc)
}
