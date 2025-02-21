//
//  HomeView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userSvc: UserService
    @EnvironmentObject private var userLikesSvc: UserLikesService
    @StateObject private var movieQueue = MovieQueue()
    @StateObject private var movieMatch = MovieMatchState()

    @State private var settingsPresented: Bool = false
    @State private var matchesPresented: Bool = false

    var body: some View {
        ZStack {
            AppGradient()

            VStack {
                HStack {
                    Button(action: { settingsPresented = true }) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    Spacer()
                    Image("md-smart")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                    Spacer()
                    Button(action: { matchesPresented = true }) {
                        Image(systemName: "heart.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                .padding(.vertical, 10)
                .foregroundStyle(.white)

                ScrollView {
                    MovieSwipeView(queue: movieQueue.queue, onAction: swipe)
                }

                HStack {
                    Button(action: { swipe(false) }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    Spacer()
                    Button(action: { swipe(true) }) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 60)
                .padding(.top, 20)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            movieQueue.fill(userSvc: userSvc, userLikesSvc: userLikesSvc)
        }
        .onChange(of: userLikesSvc.userMatches.count) { old, new in
            movieMatch.onMatchCountChange(old: old, new: new, latest: userLikesSvc.userMatches.first)
        }
        .sheet(isPresented: $settingsPresented) {
            NavigationView {
                SettingsView(isPresented: $settingsPresented)
            }
        }
        .sheet(isPresented: $matchesPresented) {
            NavigationView {
                MovieMatchesView(isPresented: $matchesPresented)
            }
        }
        .sheet(isPresented: movieMatch.show) {
            MovieMatchView(movie: $movieMatch.movie)
        }
    }

    private func swipe(_ isLike: Bool) {
        let id = movieQueue.pop()
        if let id, isLike {
            Task {
                try? await userLikesSvc.likeAndMatch(movieId: id)
            }
        }
        movieQueue.fill(userSvc: userSvc, userLikesSvc: userLikesSvc)
    }
}

#Preview {
    HomeView()
        .environmentObject(PreviewCompose.userSvc)
        .environmentObject(PreviewCompose.userLikesSvc)
}
