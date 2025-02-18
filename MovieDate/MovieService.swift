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

struct ProviderResponse: Codable {
    let results: [Provider]
}

struct Provider: Codable, Identifiable {
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
    
    var logoUrl: URL {
        return URL(string: "https://image.tmdb.org/t/p/w92\(logo_path)")!
    }
}

struct MovieResponse: Codable{
    let results: [Movie]
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let poster_path: String?
    let genre_ids: [Int]    //
    let overview: String?
    let release_date: String?
    var platforms: [Provider]?
   

    var posterURL: URL? {
        if let path = poster_path {
            return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
        }
        return nil
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
        let data = try await fetch("/3/movie/popular");
        return try JSONDecoder().decode(MovieResponse.self, from: data).results
    }

    func getGenres() async throws -> [Genre] {
        let data = try await fetch("/3/genre/movie/list")
        return try JSONDecoder().decode(GenreResponse.self, from: data).genres
    }

    func getProviders() async throws -> [Provider] {
        let query = [URLQueryItem(name: "watch_region", value: "BG")]
        let data = try await fetch("/3/watch/providers/movie", query: query)
        let results = try JSONDecoder().decode(ProviderResponse.self, from: data).results
        return results.sorted(by: { $0.display_priority < $1.display_priority })
    }

    func getPerson(id: Int) async throws -> Person {
        let data = try await fetch("/3/person/\(id)")
        return try JSONDecoder().decode(Person.self, from: data)
    }

    func searchPeople(query: String) async throws -> [Person] {
        let query = [URLQueryItem(name: "query", value: query)]
        let data = try await fetch("/3/search/person", query: query)
        let results = try JSONDecoder().decode(PersonResponse.self, from: data).results
        return results
            .filter({ $0.popularity > 1 })
            .sorted(by: { $0.popularity > $1.popularity })
    }

    private func fetch(_ endpoint: String, query: [URLQueryItem] = [], lang: String = "en") async throws -> Data {
        let url = URL(string: host + endpoint)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems = query + [
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
