//
//  MovieSwipeView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct MovieSwipeView: View {
    private let movieSvc: MovieService
    private let engine: RecommendationEngine

    @EnvironmentObject private var userSvc: UserService
    @EnvironmentObject private var userLikesSvc: UserLikesService

    @State private var shown: Set<Int> = []

    private let queueSize = 5
    @State private var queueTask: Task<(), Never>? = nil
    @State private var queue: [MovieDetails] = []

    @State private var swipeOffsets: [Int: Double] = [:]

    init() {
        movieSvc = AppCompose.movieSvc
        engine = RecommendationEngine(movieSvc: movieSvc)
    }

    var body: some View {
        ZStack {
            Style.appGradient

            VStack {
                HStack {
                    NavigationLink(destination: SettingsView()){
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
                    NavigationLink(destination: MatchedMoviesView()){
                        Image(systemName: "heart.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                .padding(.vertical, 10)
                .foregroundStyle(.white)

                ScrollView {
                    VStack {
                        if let movie = queue.last {
                            ZStack {
                                ForEach(queue) { movie in
                                    MovieCardView(movie: movie, swipeOffsets: $swipeOffsets) { action in
                                        action ? like() : dislike()
                                    }
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

                HStack {
                    Button(action: dislike) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    Spacer()
                    Button(action: like) {
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
            .task {
                fillQueue()
            }
        }
        .colorScheme(.dark)
    }

    private func like() {
        guard let id = pop() else { return }
        Task {
            try? await userLikesSvc.likeAndMatch(movieId: id)
        }
    }

    private func dislike() {
        pop()
    }

    @discardableResult
    private func pop() -> Int? {
        guard let movie = queue.last else { return nil }
        print("Swipe", movie.id)
        queue.removeLast()
        fillQueue()
        return movie.id
    }

    private func fillQueue() {
        guard let user = userSvc.user else { return }
        guard queueTask == nil else { return }
        queueTask = Task {
            while queue.count < queueSize {
                let ctx = UserContext(user: user,
                                      liked: userLikesSvc.userLikes.map{$0.movieId},
                                      partnerLiked: userLikesSvc.partnerLikes.map{$0.movieId},
                                      matched: userLikesSvc.userMatches.map{$0.movieId},
                                      shown: shown)
                let id = await engine.getRecomendation(ctx: ctx)?.id
                if let id, let movie = try? await movieSvc.getMovieDetails(id: id) {
                    shown.insert(id)
                    queue.insert(movie, at: 0)
                } else {
                    print("Engine fail. Sleeping")
                    try? await Task.sleep(for: .seconds(1))
                }
            }
            queueTask = nil
        }
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
                ForEach(providers.results["BG"]?.allUnique ?? []) { p in
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

#Preview {
    MovieSwipeView()
        .environmentObject(PreviewCompose.userSvc)
        .environmentObject(PreviewCompose.userLikesSvc)
}
