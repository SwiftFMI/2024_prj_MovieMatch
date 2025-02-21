//
//  MovieMatchesView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct MovieMatchesView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userLikesSvc: UserLikesService

    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(userLikesSvc.userMatches, id: \.movieId) { m in
                        MovieView(id: m.movieId)
                    }
                }
            }
        }
        .navigationTitle("Matches")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isPresented = false }) {
                    Text("Done")
                }
            }
        }
    }
}

fileprivate struct MovieView: View {
    private let movieSvc = AppCompose.movieSvc
    let id: Int
    @State var movie: MovieDetails? = nil
    
    var body: some View {
        HStack {
            if let movie {
                NavigationLink(destination: MovieDetailsView(movie: movie)) {
                    HStack {
                        if let posterURL = movie.posterURL {
                            AsyncImage(url: posterURL) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 80, height: 120)
                            .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            Text(movie.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(movie.year)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(movie.overview)
                                .font(.caption)
                                .lineLimit(3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .task{
            movie = try? await movieSvc.getMovieDetails(id: id)
        }
    }
}

fileprivate struct MovieDetailsView: View {
    let movie: MovieDetails

    var body: some View {
        ScrollView {
            VStack {
                if let posterURL = movie.posterURL {
                    MoviePosterView(posterURL: posterURL)
                }
                MovieContentView(movie: movie)
            }
            .padding()
        }
        .navigationTitle(movie.titleFull)
    }
}

#Preview {
    NavigationStack {
        MovieMatchesView(isPresented: .constant(true))
            .environmentObject(PreviewCompose.userLikesSvc)
    }
}
