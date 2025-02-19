//
//  RecommendationEngine.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 17.02.25.
//

import SwiftUI

class RecommendationEngine: ObservableObject {
    private let auth: AuthService
    private let movieSvc: MovieService

    private var shown: Set<Int> = []
    private var distribution: [(Int, () async -> Int?)] = []

    private let queueSize = 3
    @Published private(set) var queue: [MovieDetails] = []

    init(auth: AuthService, movieSvc: MovieService) {
        self.auth = auth
        self.movieSvc = movieSvc
        self.shown = []
        self.distribution = [
            (0, self.fromMatches),
            (0, self.fromOwnLikes),
            (0, self.fromPartnerLikes),
            (1, self.fromPopular),
            (1, self.fromSelected),
        ]
    }

    @MainActor
    func pop() async {
        guard !queue.isEmpty else { return }
        queue.removeLast()
        await fill()
    }

    @MainActor
    func fill() async {
        while queue.count < queueSize {
            let id = await getRecomendation()
            if let movie = try? await movieSvc.getMovieDetails(id: id) {
                queue.insert(movie, at: 0)
            }
        }
    }

    func getRecomendation() async -> Int {
        while true {
            if let id = await fromAny(), !shown.contains(id) {
                // TODO: Check if not liked and do what?
                shown.insert(id)
                return id
            }
        }
    }


    private func fromMatches() -> Int? {
        // TODO: Same as ownLikes but from matches
        return nil
    }

    private func fromOwnLikes() -> Int? {
        // TODO: Similar/Recommended
        return nil
    }

    private func fromPartnerLikes() -> Int? {
        // TODO: Direct choose
        return nil
    }

    private func fromPopular() async -> Int? {
        let movies = (try? await movieSvc.getPopularMovies()) ?? []
        return movies.randomElement()?.id
    }

    private func fromSelected() async -> Int? {
        guard let user = await auth.user else { return nil }
        let movies = (try? await movieSvc.discoverMovies(genres: user.selectedGenres, actors: user.selectedActors, providers: user.selectedProviders)) ?? []
        return movies.randomElement()?.id
    }

    private func fromAny() async -> Int? {
        let totalWeight = distribution.reduce(0) { res, el in res + el.0 }
        let randomValue = Int.random(in: 0..<totalWeight)
        var cumulativeWeight = 0
        for (weight, function) in distribution {
            cumulativeWeight += weight
            if randomValue < cumulativeWeight {
                return await function()
            }
        }
        return nil
    }

}
