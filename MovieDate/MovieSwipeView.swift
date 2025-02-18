//
//  MovieSwipeView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct MovieSwipeView: View {
    @StateObject private var viewModel = MovieViewModel()
    @State private var currentIndex = 0
    @State private var currentSwipeOffset: CGFloat = 0
    
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
                    ForEach(Array(viewModel.movies.enumerated()), id: \ .element.id) { index, movie in
                        if index >= currentIndex {
                            MovieCardView(movie: movie, genres: viewModel.genres)
                                .offset(x: index == currentIndex ? currentSwipeOffset : 0)
                                .zIndex(Double(viewModel.movies.count - index))
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            if index == currentIndex {
                                                currentSwipeOffset = gesture.translation.width
                                            }
                                        }
                                        .onEnded { gesture in
                                            if index == currentIndex {
                                                if gesture.translation.width < -50 {
                                                    nextMovie(isLike: false)
                                                } else if gesture.translation.width > 50 {
                                                    nextMovie(isLike: true)
                                                }
                                                currentSwipeOffset = 0
                                            }
                                        }
                                )
                        }
                    }
                    overlaySwipingIndicators
                        .zIndex(999999)
                }
                .frame(maxHeight: .infinity)
                .animation(.smooth, value: currentSwipeOffset)
                
                HStack {
                    Button(action: {
                        nextMovie(isLike: false)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.white)
                    }
                    .padding(.leading, 60)
                    Spacer()
                    
                    Button(action: {
                        nextMovie(isLike: true)
                    }) {
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
        }
        .task {
            await viewModel.loadMovies()
        }
    
    }
    
    private func nextMovie(isLike: Bool) {
        if currentIndex < viewModel.movies.count {
            currentIndex += 1
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
                .scaleEffect(abs(currentSwipeOffset) > 100 ? 1.5 : 1.0)
                .offset(x: min(-currentSwipeOffset, 150))
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
                .scaleEffect(abs(currentSwipeOffset) > 100 ? 1.5 : 1.0)
                .offset(x: max(-currentSwipeOffset, -130))
                .offset(x: 100)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .animation(.smooth, value: currentSwipeOffset)
    }
}

struct MovieCardView: View {
    let movie: Movie
    let genres: [Genre]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView {
                MovieImageView(posterURL: movie.posterURL)
                    .frame(width: 300, height: 500)
                    .cornerRadius(20)
                    .overlay(
                        VStack(alignment: .leading) {
                            GenreTagView(genreIds: movie.genre_ids, genres: genres)
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
                    
                    Text(movie.overview!)
                        .font(.body)
                        .padding()
                        .foregroundStyle(.white)
                        //.padding(.top, 10)
                    
                    HStack {
                        Text("Release date: ")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.leading, 15)
                        
                        Text(movie.release_date!)
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Text("Actors: ")
                            .padding(.top, 10)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
                        
                        
                    }
                    
                    HStack {
                        Text("Platforms: ")
                            .padding(.top, 10)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.leading, 15)
                        
                        Text(movie.platforms?.map { $0.name }.joined(separator: ", ") ?? "No platforms available")
                            .padding(.top, 10)
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    
                }
                .frame(width: 300)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
            }
        }
    }
}


struct MovieImageView: View {
    let posterURL: URL?
    
    var body: some View {
        if let url = posterURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 450)
                        .cornerRadius(20)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 450)
                        .foregroundStyle(.gray)
                default:
                    ProgressView()
                }
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 450)
                .foregroundStyle(.gray)
        }
    }
}

struct GenreTagView: View {
    let genreIds: [Int]
    let genres: [Genre]
    
    var body: some View {
        HStack {
            ForEach(genreIds, id: \.self) { genreId in
                if let genre = genres.first(where: { $0.id == genreId }) {
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
}

class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var genres: [Genre] = []
    private let movieService = MovieService()
    
    func loadMovies() async {
        do {
            self.movies = try await movieService.getPopularMovies()
            self.genres = try await movieService.getGenres()
        } catch {
            print("Error fetching movies or genres: \(error)")
        }
    }
}

#Preview {
    MovieSwipeView()
}
