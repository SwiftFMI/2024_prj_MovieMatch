//
//  MovieSwipeView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct MovieSwipeView: View {
    @EnvironmentObject private var engine: RecommendationEngine
    @State private var swipeOffsets: [Int: Double] = [:]

    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()

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
                        .frame(width: 200, height: 100)
                    Spacer()
                    NavigationLink(destination: MatchedMoviesView()){
                        Image(systemName: "heart.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)

                ScrollView {
                    VStack {
                        if let movie = engine.queue.last {
                            ZStack {
                                ForEach(engine.queue) { movie in
                                    MovieCardView(movie: movie, swipeOffsets: $swipeOffsets) { action in
                                        action ? like() : dislike()
                                    }
                                }
                                OverlaySwipingIndicatorsView(swipeOffset: swipeOffsets[movie.id] ?? 0)
                                    .zIndex(999)
                            }
                            MovieDetailsView(movie: movie)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                HStack {
                    Button(action: dislike) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Button(action: like) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 60)
                .padding(.top, 20)
            }
            .padding()
            .task {
                await engine.fill()
            }
        }
    }

    private func like() {
        Task { await engine.pop() }
        // TODO: Store in db
    }

    private func dislike() {
        Task { await engine.pop() }
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
            Text("\(movie.title) (\(movie.release_date.prefix(4)))")
                .multilineTextAlignment(.center)
                .font(.title2)
                .bold()
                .foregroundStyle(.white)
                .padding(.top, 5)

            Text(movie.overview)
                .font(.body)
                .padding(.vertical)
                .foregroundStyle(.white)

            HStack {
                Text("Release date: ")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.vertical)
                Text(movie.release_date)
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack {
                Text("Cast: ")
                    .padding(.vertical)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(movie.credits.cast.prefix(10).map{ $0.name }.joined(separator: ", "))
                    .foregroundStyle(.white)
            }

            VStack {
                Text("Watch: ")
                    .padding(.vertical)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(movie.providers.results["BG"]?.all.map { $0.name }.joined(separator: ", ") ?? "Not available")
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
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
        AsyncImage(url: posterURL) { image in
            image.resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(20)
        } placeholder: {
            ProgressView().colorScheme(.dark)
                .frame(maxWidth: .infinity)
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
        .environmentObject(RecommendationEngine(auth: AuthService.preview, movieSvc: MovieService()))
}
