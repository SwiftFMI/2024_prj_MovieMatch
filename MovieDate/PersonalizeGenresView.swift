//
//  MoviesGenresView.swift
//  MovieDate
//
//  Created by Darina Baneva on 10.02.25.
//

import SwiftUI

struct PersonalizeGenresView: View {
    private let movieSvc = AppCompose.movieSvc

    @EnvironmentObject private var userSvc: UserService
    @State private var genres: [Genre] = []

    var body: some View {
        ZStack {
            AppGradient()
            
            VStack {
                ProgressView(value: 1.0/3)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 150)
                    .padding(.top, 20)
                    .tint(.red)
                
                Text("What genres do you like?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                ScrollView {
                    VStack {
                        ForEach(genres) { genre in
                            if let user = userSvc.user {
                                let isSelected = user.selectedGenres.contains(genre.id) == true
                                let icon = Text(genre.icon).font(.title)
                                SelectableButton(icon: icon, text: genre.name, isSelected: isSelected) {
                                    userSvc.updateUserSelect(key: .selectedGenres, id: genre.id, isSelected: !isSelected)
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                }

                NavigationLink(destination: PersonalizeActorsView()) {
                    Text("Continue")
                        .padding()
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
        .onAppear(perform: fetchGenres)
    }

    private func fetchGenres() {
        Task {
            do {
                self.genres = try await movieSvc.getGenres()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    PersonalizeGenresView()
        .environmentObject(PreviewCompose.userSvc)
}
