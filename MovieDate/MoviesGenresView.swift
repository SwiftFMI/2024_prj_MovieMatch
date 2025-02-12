//
//  MoviesGenresView.swift
//  MovieDate
//
//  Created by Darina Baneva on 10.02.25.
//

import SwiftUI

struct MoviesGenresView: View {
    @State private var selectedGenres: [Int] = []
    @State private var genres: [Genre] = []

    let genreEmojis: [String: String] = [
        "Romance": "💖",
        "Drama": "🎭",
        "Documentary": "🎥",
        "Action": "🧨",
        "Adventure": "🧭",
        "Horror": "👻",
        "Thriller": "🔪",
        "Mystery": "🔮",
        "Fantasy": "🦄",
        "Science Fiction": "👽",
        "Comedy": "😂",
        "Family": "🏡",
        "Animation": "🧸",
        "Crime": "🕵🏻‍♂️",
        "History": "🏛",
        "Music": "🎵",
        "TV Movie": "📺",
        "War": "⚔️",
        "Western": "🤠"
    ]
    
    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()
            
            VStack {
                ProgressView(value: 0.3)
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
                            let emoji = genreEmojis[genre.name] ?? "🎬"
                            GenreButton(icon: emoji, text: genre.name, isSelected: selectedGenres.contains(genre.id)) {
                                toggleGenre(genre.id)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                
                NavigationLink(destination: ActorsView()) {
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
        .onAppear {
            fetchGenres()
        }
    }
    
    func fetchGenres() {
        let apiKey = "e13c8c80bb7b14cf140adb8aa6dd234d"
        let urlString = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(GenreResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.genres = decodedResponse.genres
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    private func toggleGenre(_ genreId: Int) {
        if selectedGenres.contains(genreId) {
            selectedGenres.removeAll { $0 == genreId }
        } else {
            selectedGenres.append(genreId)
        }
    }
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct GenreButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.title)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.white.opacity(0.7) : Color.white.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    MoviesGenresView()
}
