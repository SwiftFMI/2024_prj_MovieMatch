//
//  MovieMatchState.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 21.02.25.
//

import SwiftUI

@MainActor
class MovieMatchState: ObservableObject {
    private let movieSvc = AppCompose.movieSvc
    @Published var movie: MovieDetails? = nil
    var show: Binding<Bool> {
        Binding {
            self.movie != nil
        }
        set: { val in
            if !val { self.movie = nil }
        }
    }

    func onMatchCountChange(old: Int, new: Int, latest: UserMatch?) {
        if new - old == 1 {
            Task {
                if let id = latest?.movieId {
                    movie = try? await movieSvc.getMovieDetails(id: id)
                }
            }
        }
    }
}
