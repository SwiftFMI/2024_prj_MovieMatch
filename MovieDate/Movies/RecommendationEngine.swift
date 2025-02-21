//
//  RecommendationEngine.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 17.02.25.
//

struct UserContext {
    let user: User
    let liked: [Int]
    let partnerLiked: [Int]
    let matched: [Int]
    let shown: Set<Int>
}

struct Recommendation {
    enum Reason {
        case fromMatch(id: Int)
        case fromOwnLike(id: Int)
        case fromPartnerLikes
        case fromSelected
        case fromPopular
    }

    let id: Int
    let reason: Reason

    init(_ id: Int, _ reason: Reason) {
        self.id = id
        self.reason = reason
    }
}

class RecommendationEngine {
    private let movieSvc: MovieService

    private var providers: [(Int, (UserContext) async -> Recommendation?)] = []

    init(movieSvc: MovieService) {
        self.movieSvc = movieSvc
        self.providers = [
            (25, self.fromMatches),
            (25, self.fromOwnLikes),
            (25, self.fromPartnerLikes),
            (20, self.fromSelected),
            (10, self.fromPopular),
        ]
    }

    func getRecomendation(ctx: UserContext) async -> Recommendation? {
        if let rec = await fromProvider(ctx), isAvailabe(ctx, id: rec.id) {
            return rec
        }
        return nil
    }

    private func fromProvider(_ ctx: UserContext) async -> Recommendation? {
        var possibleProviders = providers
        while !possibleProviders.isEmpty {
            let totalWeight = possibleProviders.reduce(0) { pw, p in pw + p.0 }
            let randomValue = Int.random(in: 0..<totalWeight)
            var cumulativeWeight = 0
            for (i, provider) in possibleProviders.enumerated() {
                let (weight, call) = provider
                cumulativeWeight += weight
                if randomValue < cumulativeWeight {
                    let rec = await call(ctx)
                    if let rec {
                        return rec
                    } else {
                        possibleProviders.remove(at: i)
                        break
                    }
                }
            }
        }
        return nil
    }


    private func fromMatches(ctx: UserContext) async -> Recommendation? {
        guard let matchId = ctx.matched.randomElement() else { return nil }
        guard let id = await fromRelated(ctx: ctx, id: matchId) else { return nil }
        return Recommendation(id, .fromMatch(id: matchId))
    }

    private func fromOwnLikes(ctx: UserContext) async -> Recommendation? {
        guard let likeId = ctx.liked.randomElement() else { return nil }
        guard let id = await fromRelated(ctx: ctx, id: likeId) else { return nil }
        return Recommendation(id, .fromOwnLike(id: id))
    }

    private func fromPartnerLikes(ctx: UserContext) -> Recommendation? {
        guard let id = ctx.partnerLiked
            .filter({isAvailabe(ctx, id: $0)})
            .randomElement() else { return nil }
        return Recommendation(id, .fromPartnerLikes)
    }

    private func fromSelected(ctx: UserContext) async -> Recommendation? {
        let id = await fromQuery(ctx: ctx, attempts: 5, maxPage: 100) { page in
            try await movieSvc.discoverMovies(
                genres: ctx.user.selectedGenres,
                actors: ctx.user.selectedActors,
                providers: ctx.user.selectedProviders,
                page: page)
        }
        guard let id else { return nil }
        return Recommendation(id, .fromSelected)
    }

    private func fromPopular(ctx: UserContext) async -> Recommendation? {
        let id = await fromQuery(ctx: ctx, attempts: 5, maxPage: 100) { page in
            try await movieSvc.discoverMovies(
                providers: ctx.user.selectedProviders,
                page: page)
        }
        guard let id else { return nil }
        return Recommendation(id, .fromPopular)
    }

    private func fromRelated(ctx: UserContext, id: Int) async -> Int? {
        return await fromQuery(ctx: ctx, attempts: 2, maxPage: 4) { page in
            try await movieSvc.getRecommendation(id: id, page: page)
        }
    }

    private func fromQuery(ctx: UserContext,
                           attempts: Int,
                           maxPage: Int,
                           call: (Int) async throws -> MovieResponse) async -> Int? {
        var page = 1
        for _ in 1...attempts {
            let res = try? await call(page)
            guard let res else {
                page = 1
                continue
            }
            let matches = res.results.filter{isAvailabe(ctx, id: $0.id)}
            if let m = matches.randomElement() {
                return m.id
            }
            page = Int.random(in: 1...max(min(res.total_pages, maxPage), 1))
        }
        return nil
    }

    private func isAvailabe(_ ctx: UserContext, id: Int) -> Bool {
        return !ctx.shown.contains(id) && !ctx.liked.contains(id)
    }
}
