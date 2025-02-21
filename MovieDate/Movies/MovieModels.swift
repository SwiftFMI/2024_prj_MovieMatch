//
//  MovieModels.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 19.02.25.
//

import Foundation

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
    let vote_average: Double
    let vote_count: Int
    let genres: [Genre]
    let credits: MovieCredits
    let providers: MovieWatchProviders

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case poster_path
        case overview
        case release_date
        case vote_average
        case vote_count
        case genres
        case credits
        case providers = "watch/providers"
    }

    var year: String { String(release_date.prefix(4)) }
    var titleFull: String { "\(title) (\(year))" }
    var posterURL: URL? { imageUrl(size: "w500", path: poster_path) }
}

struct MovieCredits: Codable {
    let cast: [Person]
    let crew: [Person]
    
    var castSelection: [Person] {
        cast.unique()
    }
    var crewSelection: [Person] {
        ["Director", "Writer"]
            .flatMap({ j in crew.filter({ $0.job == j }) })
            .unique()
    }
}

struct MovieWatchProviders: Codable {
    let results: [String: MovieWatchProviderRegion]
    var local: MovieWatchProviderRegion? { results["BG"] }
}

struct MovieWatchProviderRegion: Codable {
    let buy: [WatchProvider]?
    let rent: [WatchProvider]?
    let flatrate: [WatchProvider]?

    var allUnique: [WatchProvider] {
        [buy, rent, flatrate]
            .compactMap{ $0 }
            .flatMap{ $0 }
            .unique()
    }
}

struct Person: Identifiable, Codable {
    let id: Int
    let name: String
    let popularity: Double
    let profile_path: String?
    let job: String?

    var profileUrl: URL? {
        imageUrl(size: "w185", path: profile_path)
    }
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


fileprivate func imageUrl(size: String, path: String?) -> URL? {
    guard let path else { return nil }
    return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
}

fileprivate extension Sequence where Element: Identifiable {
    func unique() -> [Element] {
        return reduce(into: [], { res, curr in
            if !res.contains(where: { p in p.id == curr.id }) {
                res.append(curr)
            }
        })
    }
}
