//
//  MovieSwipeView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct MovieSwipeView: View {
    @EnvironmentObject private var engine: RecommendationEngine
    @State private var swipeOffset: Double = 0

    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()
            
            VStack {
                Image("md-smart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
                    .foregroundStyle(.white)
                
                HStack {
                    NavigationLink(destination: SettingsView()){
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.white)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    NavigationLink(destination: MatchedMoviesView()){
                        Image(systemName: "heart.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing, 20)
                }
                
                ZStack {
                    ForEach(Array(engine.queue.enumerated()), id: \.0) { i, movie in
                        MovieCardView(movie: movie)
                            .offset(x: i == engine.queue.count - 1 ? swipeOffset : 0)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        swipeOffset = gesture.translation.width
                                    }
                                    .onEnded { gesture in
                                        if gesture.translation.width < -50 {
                                            dislike()
                                        } else if gesture.translation.width > 50 {
                                            like()
                                        }
                                        swipeOffset = 0
                                    }
                            )
                        
                    }
                    overlaySwipingIndicators
                        .zIndex(999999)
                }
                .frame(maxHeight: .infinity)
                .animation(.smooth, value: swipeOffset)
                
                HStack {
                    Button(action: dislike) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.white)
                    }
                    .padding(.leading, 60)
                    Spacer()
                    
                    Button(action: like) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing, 60)
                }
                .padding()
            }
            .padding()
            .task {
                await engine.fill()
            }
        }
    }

    private var overlaySwipingIndicators: some View {
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

    private func like() {
        Task { await engine.pop() }
        // TODO: Store in db
    }

    private func dislike() {
        Task { await engine.pop() }
    }
}

struct MovieCardView: View {
    let movie: MovieDetails

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView {
                MovieImageView(posterURL: movie.posterURL!)
                    .frame(width: 300, height: 500)
                    .cornerRadius(20)
                    .overlay(
                        VStack(alignment: .leading) {
                            GenreTagView(genres: movie.genres)
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(20)
                        .padding(.leading)
                        .padding(.bottom, 30),
                        alignment: .bottomLeading
                    )

                VStack {
                    Text(movie.title)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.top, 5)

                    Text("Overview: ")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.top, 10)
                    
                    Text(movie.overview)
                        .font(.body)
                        .padding()
                        .foregroundStyle(.white)
                    
                    HStack {
                        Text("Release date: ")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.leading, 15)
                        Text(movie.release_date)
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Text("Cast: ")
                            .padding(.top, 10)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
                        Text(movie.credits.cast.map{ $0.name }.joined(separator: ", "))
                            .foregroundStyle(.white)
                    }

//                    HStack {
//                        Text("Platforms: ")
//                            .padding(.top, 10)
//                            .font(.title3)
//                            .bold()
//                            .foregroundStyle(.white)
//                            .padding(.leading, 15)
//                        
//                        Text(movie.platforms?.map { $0.name }.joined(separator: ", ") ?? "No platforms available")
//                            .padding(.top, 10)
//                            .font(.body)
//                            .foregroundStyle(.white)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
                    
                }
                .frame(width: 300)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
            }
        }
    }
}


fileprivate struct MovieImageView: View {
    let posterURL: URL
    
    var body: some View {
        AsyncImage(url: posterURL) { image in
            image.resizable()
                .scaledToFit()
                .frame(width: 300, height: 450)
                .cornerRadius(20)
        } placeholder: {
            ProgressView().colorScheme(.dark)
                .frame(width: 300, height: 450)
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
    }
}

#Preview {
    MovieSwipeView()
}
