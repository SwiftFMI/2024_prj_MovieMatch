//
//  MovieService.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import Foundation

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String

    var icon: String {
        return [
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
        ][name] ?? "🎬"
    }
}

struct WatchProviderResponse: Codable {
    let results: [WatchProvider]
}

struct WatchProvider: Codable, Identifiable {
    let id: Int
    let name: String
    let display_priority: Int
    let logo_path: String

    enum CodingKeys: String, CodingKey {
        case id = "provider_id"
        case name = "provider_name"
        case display_priority
        case logo_path
    }
    
    var logoUrl: URL { imageUrl(size: "w92", path: logo_path)! }
}

struct MovieResponse: Codable{
    let results: [Movie]
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let poster_path: String?

    var posterURL: URL? { imageUrl(size: "w500", path: poster_path) }
}

struct MovieDetails: Codable, Identifiable {
    let id: Int
    let title: String
    let poster_path: String?
    let overview: String
    let release_date: String
    let genres: [Genre]
    let credits: MovieCredits
    let providers: MovieWatchProviders
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case poster_path
        case overview
        case release_date
        case genres
        case credits
        case providers = "watch/providers"
    }

    var posterURL: URL? { imageUrl(size: "w500", path: poster_path) }
}

struct MovieCredits: Codable {
    let cast: [Person]
    let crew: [Person]
}

struct MovieWatchProviders: Codable {
    let results: [String: MovieWatchProviderRegion]
}

struct MovieWatchProviderRegion: Codable {
    let buy: [WatchProvider]?
    let rent: [WatchProvider]?
    let flatrate: [WatchProvider]?
    
    var all: [WatchProvider] {
        [buy, rent, flatrate].compactMap{ $0 }.flatMap{ $0 }
    }
}

struct Person: Identifiable, Codable {
    let id: Int
    let name: String
    let popularity: Double
}

struct PersonResponse: Codable {
    let results: [Person]
}

func imageUrl(size: String, path: String?) -> URL? {
    guard let path = path else { return nil }
    return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
}

class MovieService {
    private let host = "https://api.themoviedb.org"
    private let apiKey = "e13c8c80bb7b14cf140adb8aa6dd234d"
    private let apiReadToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlMTNjOGM4MGJiN2IxNGNmMTQwYWRiOGFhNmRkMjM0ZCIsIm5iZiI6MTczNDYwNzg5OS45NjUsInN1YiI6IjY3NjQwNDFiZTE0ZTNiY2ZhNzRhNGEzNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.wkdU83BIfm5cmiVbgkn_7red1z2Q1sZEeY8sHflqzKU"
    private let session: URLSession

    init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: sessionConfig)
    }

    func getPopularMovies() async throws -> [Movie] {
        let data = try await fetch("/3/movie/popular")
        return try JSONDecoder().decode(MovieResponse.self, from: data).results
    }

    func discoverMovies(genres: [Int], actors: [Int], providers: [Int]) async throws -> [Movie] {
        var query: [(String, String)] = []
        if !genres.isEmpty {
            query.append(("with_genres", filter(genres, sep: "|")))
        }
        if !actors.isEmpty {
            query.append(("with_cast", filter(actors, sep: "|")))
        }
        if !providers.isEmpty {
            query.append(("watch_region", "BG"))
            query.append(("with_watch_providers", filter(providers, sep: "|")))
        }
        let data = try await fetch("/3/discover/movie", query: query)
        return try JSONDecoder().decode(MovieResponse.self, from: data).results
    }
    
    func getMovieDetails(id: Int) async throws -> MovieDetails {
        let query = [
            ("append_to_response", "credits,watch/providers"),
        ]
        let data = try await fetch("/3/movie/\(id)", query: query)
        return try JSONDecoder().decode(MovieDetails.self, from: data)
    }

    func getGenres() async throws -> [Genre] {
        let data = try await fetch("/3/genre/movie/list")
        return try JSONDecoder().decode(GenreResponse.self, from: data).genres
    }

    func getProviders() async throws -> [WatchProvider] {
        let query = [("watch_region", "BG")]
        let data = try await fetch("/3/watch/providers/movie", query: query)
        let results = try JSONDecoder().decode(WatchProviderResponse.self, from: data).results
        return results.sorted(by: { $0.display_priority < $1.display_priority })
    }

    func getPerson(id: Int) async throws -> Person {
        let data = try await fetch("/3/person/\(id)")
        return try JSONDecoder().decode(Person.self, from: data)
    }

    func searchPeople(query: String) async throws -> [Person] {
        let query = [("query", query)]
        let data = try await fetch("/3/search/person", query: query)
        let results = try JSONDecoder().decode(PersonResponse.self, from: data).results
        return results
            .filter({ $0.popularity > 1 })
            .sorted(by: { $0.popularity > $1.popularity })
    }

    private func filter(_ ids: [Int], sep: String) -> String {
        return ids.map{String($0)}.joined(separator: sep)
    }

    private func fetch(_ endpoint: String, query: [(String, String)] = [], lang: String = "en") async throws -> Data {
        let url = URL(string: host + endpoint)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems = query.map{ (n, v) in URLQueryItem(name: n, value: v)} + [
          URLQueryItem(name: "language", value: lang),
        ]
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(apiReadToken)",
        ]

        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            return cachedResponse.data
        }

        let (data, _) = try await self.session.data(for: request)
        print("Fetched \(endpoint)")
        return data
    }
}
