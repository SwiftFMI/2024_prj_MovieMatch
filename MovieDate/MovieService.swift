//
//  MovieService.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import Foundation

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

class MovieService {
    private let host = "https://api.themoviedb.org"
    private let apiKey = "e13c8c80bb7b14cf140adb8aa6dd234d"
    private let apiReadToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlMTNjOGM4MGJiN2IxNGNmMTQwYWRiOGFhNmRkMjM0ZCIsIm5iZiI6MTczNDYwNzg5OS45NjUsInN1YiI6IjY3NjQwNDFiZTE0ZTNiY2ZhNzRhNGEzNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.wkdU83BIfm5cmiVbgkn_7red1z2Q1sZEeY8sHflqzKU"

    func getGenres() async throws -> [Genre] {
        let data = try await fetch("/3/genre/movie/list")
        print(String(decoding: data, as: UTF8.self))
        return try JSONDecoder().decode(GenreResponse.self, from: data).genres
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

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
