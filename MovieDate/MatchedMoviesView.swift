//
//  MatchedMoviesView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct MatchedMoviesView: View {
    @EnvironmentObject var userLikesSvc: UserLikesService

    var body: some View {
        ZStack {
            Style.appGradient
            VStack {
                Text("Matched")
                    .font(.title)
                    .bold()

                ScrollView {
                    ForEach(userLikesSvc.userMatches, id: \.movieId) { m in
                        MovieView(id: m.movieId)
                    }
                }
            }
            .padding()
        }
        .colorScheme(.dark)
    }
}

fileprivate struct MovieView: View {
    private let movieSvc = AppCompose.movieSvc
    let id: Int
    @State var movie: MovieDetails? = nil
    
    var body: some View {
        HStack {
            if let movie {
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
        .task{
            movie = try? await movieSvc.getMovieDetails(id: id)
        }
    }
}

#Preview {
    NavigationStack {
        MatchedMoviesView()
            .environmentObject(PreviewCompose.userLikesSvc)
    }
}
