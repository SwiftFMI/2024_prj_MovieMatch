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
                MovieDetailsView(movie: movie)
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
            .cornerRadius(20)
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

fileprivate struct MovieDetailsView: View {
    let movie: MovieDetails

    var body: some View {
        VStack {
            Text("\(movie.title) (\(movie.year))")
                .multilineTextAlignment(.center)
                .font(.title2)
                .bold()
                .padding(.top, 5)

            Text(movie.overview)
                .font(.body)
                .padding(.vertical)

            HStack {
                Text("Released")
                    .font(.title3)
                    .bold()
                    .padding(.vertical)
                Text(movie.release_date)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack {
                Text("Cast")
                    .padding(.vertical)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                CastView(cast: movie.credits.cast)
            }

            VStack {
                Text("Watch")
                    .padding(.vertical)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                ProvidersView(providers: movie.providers)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .colorScheme(.dark)
        .cornerRadius(20)
    }
}

fileprivate struct CastView: View {
    let cast: [Person]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(cast.prefix(10)) { p in
                    VStack {
                        AsyncImage(url: p.profileUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        Text(p.name)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 100)
                    .padding(.horizontal, 5)
                }
            }
        }
    }
}

fileprivate struct ProvidersView: View {
    let providers: MovieWatchProviders

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(providers.local?.allUnique ?? []) { p in
                    VStack {
                        AsyncImage(url: p.logoUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 80, height: 80)
                        Text(p.name)
                    }
                }
            }
        }
    }
}

fileprivate struct MoviePosterView: View {
    let posterURL: URL

    var body: some View {
        ZStack {
            Rectangle().fill(.black)
                .frame(maxWidth: .infinity)
                .aspectRatio(2/3, contentMode: .fit)
            AsyncImage(url: posterURL) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            } placeholder: {
                ProgressView()
            }
        }
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
