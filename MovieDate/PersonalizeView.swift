//
//  PersonalizationView.swift
//  MovieDate
//
//  Created by Darina Baneva on 10.02.25.
//

import SwiftUI

struct PersonalizeView: View {
    private let movieSvc = AppCompose.movieSvc

    @State private var movies: [Movie] = []
    
    var body: some View {
        ZStack {
            Style.appGradient
            
            VStack{
                PersonalizeMovieGridView(movies: movies)
                    .frame(height: 250)
                    .padding(.top, 20)
                
                Spacer()
                
                    .padding(.top, 20)
                
                Text("Let’s personalise your experience!")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(.horizontal, 30)

                Text("Answer a few quick questions!")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 10)
                
                
                NavigationLink(destination: PersonalizeGenresView()) {
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
        }
        .onAppear(perform: fetchPopularMovies)
    }

    private func fetchPopularMovies() {
        Task {
            do {
                let movies = try await movieSvc.getPopularMovies()
                self.movies = Array(movies.prefix(10))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

fileprivate struct PersonalizeMovieGridView: View {
    let movies: [Movie]
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                
                ForEach(movies.prefix(5)) { movie in
                    PersonalizeMoviePosterView(movie: movie)
                        
                }
                .padding(.top, 40)
            }
            .padding(20)
            
            HStack {
                ForEach(movies.dropFirst(5).prefix(5)) { movie in
                    PersonalizeMoviePosterView(movie: movie)
                }
            }
        }
    }
}

fileprivate struct PersonalizeMoviePosterView: View {
    let movie: Movie
    
    var body: some View {
        if let posterURL = movie.posterURL {
            AsyncImage(url: posterURL) { image in
                image.resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 100, height: 140)
                    .rotationEffect(.degrees(Double.random(in: -15...15)))
                    
            } placeholder: {
                ProgressView().colorScheme(.dark)
                    .frame(width: 100, height: 140)
            }
        } else {
            Color.gray
                .frame(width: 100, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(Text("No Image").foregroundColor(.white))
        }
    }
}

#Preview {
    PersonalizeView()
}
