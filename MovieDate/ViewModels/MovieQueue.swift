//
//  MovieQueue.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 20.02.25.
//


import SwiftUI

@MainActor
class MovieQueue: ObservableObject {
    private let movieSvc: MovieService
    private let engine: RecommendationEngine

    private let queueSize = 5
    private var queueTask: Task<(), Never>? = nil
    @Published private var shown: Set<Int> = []
    @Published var queue: [MovieDetails] = []

    init() {
        movieSvc = AppCompose.movieSvc
        engine = RecommendationEngine(movieSvc: movieSvc)
    }

    @discardableResult
    func pop() -> Int? {
        guard let movie = queue.last else { return nil }
        print("Popped", movie.id)
        queue.removeLast()
        return movie.id
    }

    func fill(userSvc: UserService, userLikesSvc: UserLikesService) {
        guard let user = userSvc.user else { return }
        guard queueTask == nil else { return }
        queueTask = Task {
            while queue.count < queueSize {
                let ctx = UserContext(user: user,
                                      liked: userLikesSvc.userLikes.map{$0.movieId},
                                      partnerLiked: userLikesSvc.partnerLikes.map{$0.movieId},
                                      matched: userLikesSvc.userMatches.map{$0.movieId},
                                      shown: shown)
                if let rec = await engine.getRecomendation(ctx: ctx),
                   let movie = try? await movieSvc.getMovieDetails(id: rec.id) {
                    print("Recommend", rec.id, rec.reason)
                    shown.insert(rec.id)
                    queue.insert(movie, at: 0)
                } else {
                    print("Recommend fail! Sleeping...")
                    try? await Task.sleep(for: .seconds(1))
                }
            }
            queueTask = nil
        }
    }
}
