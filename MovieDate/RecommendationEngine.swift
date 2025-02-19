//
//  RecommendationEngine.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 17.02.25.
//

import SwiftUI

@MainActor
class RecommendationEngine: ObservableObject {
    private let userSvc: UserService
    private let userLikesSvc: UserLikesService
    private let movieSvc: MovieService

    private var shown: Set<Int> = []
    private var distribution: [(Int, () async -> Int?)] = []

    private let queueSize = 3
    @Published private(set) var queue: [MovieDetails] = []

    init(userSvc: UserService, userLikesSvc: UserLikesService, movieSvc: MovieService) {
        self.userSvc = userSvc
        self.userLikesSvc = userLikesSvc
        self.movieSvc = movieSvc
        self.shown = []
        self.distribution = [
            (0, self.fromMatches),
            (0, self.fromOwnLikes),
            (0, self.fromPartnerLikes),
            (2, self.fromSelected),
            (1, self.fromPopular),
        ]
    }

    func like(id: Int, liked: Bool) async {
        if (liked) {
            try? await userLikesSvc.likeAndMatch(movieId: id)
        }
        await pop()
    }

    func pop() async {
        guard !queue.isEmpty else { return }
        queue.removeLast()
        await fill()
    }

    func fill() async {
        while queue.count < queueSize {
            let id = await getRecomendation()
            if let id, let movie = try? await movieSvc.getMovieDetails(id: id) {
                queue.insert(movie, at: 0)
            }
            try? await Task.sleep(for: .seconds(1))
        }
    }

    func getRecomendation() async -> Int? {
        if let id = await fromAny(), isAvailabe(id: id) {
            shown.insert(id)
            return id
        }
        return nil
    }


    private func fromMatches() -> Int? {
        print(#function)
        // TODO: Same as ownLikes but from matches
        return nil
    }

    private func fromOwnLikes() -> Int? {
        print(#function)
        // TODO: Similar/Recommended
        return nil
    }

    private func fromPartnerLikes() -> Int? {
        print(#function)
        // TODO: Direct choose
        return nil
    }

    private func fromSelected() async -> Int? {
        print(#function)
        guard let user = userSvc.user else { return nil }
        let movies = (try? await movieSvc.discoverMovies(genres: user.selectedGenres, actors: user.selectedActors, providers: user.selectedProviders)) ?? []
        return movies.filter{isAvailabe(id: $0.id)}.randomElement()?.id
    }

    private func fromPopular() async -> Int? {
        print(#function)
        let movies = (try? await movieSvc.getPopularMovies()) ?? []
        return movies.filter{isAvailabe(id: $0.id)}.randomElement()?.id
    }

    private func isAvailabe(id: Int) -> Bool {
        return !shown.contains(id) //&& !auth.userLikes.contains(id)
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
