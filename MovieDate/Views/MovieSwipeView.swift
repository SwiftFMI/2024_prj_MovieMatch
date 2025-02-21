//
//  MovieSwipeView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct MovieSwipeView: View {
    let queue: [MovieDetails]
    let onAction: (Bool) -> ()

    @State private var swipeOffsets: [Int: Double] = [:]

    var body: some View {
        VStack {
            if let movie = queue.last {
                ZStack {
                    ForEach(queue) { movie in
                        MovieCardView(movie: movie, swipeOffsets: $swipeOffsets, onAction: onAction)
                    }
                    OverlaySwipingIndicatorsView(swipeOffset: swipeOffsets[movie.id] ?? 0)
                        .zIndex(999)
                }
                MovieContentView(movie: movie)
            } else {
                ProgressView().colorScheme(.dark)
            }
        }
    }
}

fileprivate struct MovieCardView: View {
    let movie: MovieDetails
    @Binding var swipeOffsets: [Int: Double]
    let onAction: (Bool) -> ()

    var body: some View {
        MoviePosterView(posterURL: movie.posterURL!)
            .overlay(GenreTagView(genres: movie.genres), alignment: .bottom)
            .offset(x: swipeOffsets[movie.id] ?? 0)
            .rotationEffect(.degrees(Double(swipeOffsets[movie.id] ?? 0) / 30))
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        swipeOffsets[movie.id] = gesture.translation.width
                    }
                    .onEnded { gesture in
                        let translationAmount = gesture.translation.width
                        if abs(translationAmount) > 100 {
                            onAction(translationAmount > 0)
                        }
                        swipeOffsets.removeValue(forKey: movie.id)
                    }
            )
            .animation(.smooth, value: swipeOffsets)
    }
}

fileprivate struct GenreTagView: View {
    let genres: [Genre]

    var body: some View {
        HStack {
            ForEach(genres) { genre in
                Text("\(genre.icon) \(genre.name)")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(2)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(20)
        .padding(.bottom, 10)
    }
}

fileprivate struct OverlaySwipingIndicatorsView: View {
    let swipeOffset: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red.opacity(0.7))
                .overlay(
                    Image(systemName: "xmark")
                        .font(.title)
                        .fontWeight(.semibold)
                )
                .frame(width: 60, height: 60)
                .scaleEffect(abs(swipeOffset) > 100 ? 1.5 : 1.0)
                .offset(x: min(-swipeOffset, 150))
                .offset(x: -130)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Circle()
                .fill(Color.green.opacity(0.7))
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.title)
                        .fontWeight(.semibold)
                )
                .frame(width: 60, height: 60)
                .scaleEffect(abs(swipeOffset) > 100 ? 1.5 : 1.0)
                .offset(x: max(-swipeOffset, -130))
                .offset(x: 100)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .animation(.smooth, value: swipeOffset)
    }
}

#Preview {
    struct MovieSwipeViewPreview: View {
        @State var queue: [MovieDetails] = []
        var body: some View {
            ScrollView {
                MovieSwipeView(queue: queue, onAction: { a in })
                    .task {
                        if let movie = try? await AppCompose.movieSvc.getMovieDetails(id: 993710) {
                            queue = [movie]
                        }
                    }
            }
        }
    }
    return MovieSwipeViewPreview()
}
