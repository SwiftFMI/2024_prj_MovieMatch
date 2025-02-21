//
//  MovieService.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import Foundation

struct MovieResponse: Codable{
    let total_pages: Int
    let total_results: Int
    let results: [Movie]
}

struct WatchProviderResponse: Codable {
    let results: [WatchProvider]
}

struct PersonResponse: Codable {
    let results: [Person]
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

class MovieService {
    private let host = "https://api.themoviedb.org"
    private let apiKey = "e13c8c80bb7b14cf140adb8aa6dd234d"
    private let apiReadToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlMTNjOGM4MGJiN2IxNGNmMTQwYWRiOGFhNmRkMjM0ZCIsIm5iZiI6MTczNDYwNzg5OS45NjUsInN1YiI6IjY3NjQwNDFiZTE0ZTNiY2ZhNzRhNGEzNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.wkdU83BIfm5cmiVbgkn_7red1z2Q1sZEeY8sHflqzKU"

    private let lang: String
    private let session: URLSession

    init(lang: String = "en-US") {
        self.lang = lang
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: sessionConfig)
    }

    func getPopularMovies() async throws -> [Movie] {
        return try await discoverMovies().results
    }

    func discoverMovies(genres: [Int]  = [],
                        actors: [Int] = [],
                        providers: [Int] = [],
                        page: Int = 1) async throws -> MovieResponse {
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
        query.append(("page", String(page)))
        return try await fetch(as: MovieResponse.self, "/3/discover/movie", query: query)
    }

    func getRecommendation(id: Int, page: Int = 1) async throws -> MovieResponse {
        let query = [("page", String(page))]
        return try await fetch(as: MovieResponse.self, "/3/movie/\(id)/recommendations", query: query)
    }

    func getSimilar(id: Int, page: Int = 1) async throws -> MovieResponse {
        let query = [("page", String(page))]
        return try await fetch(as: MovieResponse.self, "/3/movie/\(id)/similar", query: query)
    }

    func getMovieDetails(id: Int) async throws -> MovieDetails {
        let query = [
            ("append_to_response", "credits,watch/providers"),
        ]
        return try await fetch(as: MovieDetails.self, "/3/movie/\(id)", query: query)
    }
    
    func getMovieProviders(id: Int) async throws -> MovieWatchProviders {
        return try await fetch(as: MovieWatchProviders.self, "/3/movie/\(id)/watch/providers")
    }

    func getGenres() async throws -> [Genre] {
        return try await fetch(as: GenreResponse.self, "/3/genre/movie/list").genres
    }

    func getProviders() async throws -> [WatchProvider] {
        let query = [("watch_region", "BG")]
        let results = try await fetch(as: WatchProviderResponse.self, "/3/watch/providers/movie", query: query).results
        return results.sorted(by: { $0.display_priority < $1.display_priority })
    }

    func getPerson(id: Int) async throws -> Person {
        return try await fetch(as: Person.self, "/3/person/\(id)")
    }

    func searchPeople(query: String) async throws -> [Person] {
        let query = [("query", query)]
        let results = try await fetch(as: PersonResponse.self, "/3/search/person", query: query).results
        return results
            .filter({ $0.popularity > 1 })
            .sorted(by: { $0.popularity > $1.popularity })
    }

    private func filter(_ ids: [Int], sep: String) -> String {
        return ids.map{String($0)}.joined(separator: sep)
    }

    private func fetch<T: Decodable>(as: T.Type, _ endpoint: String, query: [(String, String?)] = []) async throws -> T {
        let data = try await fetch(endpoint, query: query)
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("Decode error", error.localizedDescription)
            throw error
        }
    }

    private func fetch(_ endpoint: String, query: [(String, String?)] = []) async throws -> Data {
        let url = URL(string: host + endpoint)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queryItems = query.map{ (n, v) in URLQueryItem(name: n, value: v)}
        queryItems.append(URLQueryItem(name: "language", value: self.lang))
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

        do {
            let (data, response) = try await self.session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { throw URLError(.badServerResponse) }
            return data
        } catch {
            print("Fetch error", error)
            throw error
        }
    }
}
