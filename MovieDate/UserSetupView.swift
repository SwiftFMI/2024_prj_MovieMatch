//
//  SetupView.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 12.02.25.
//

import SwiftUI

struct UserSetupStreamingView: View {
    var body: some View {
        VStack {
            Text("Select your streaming platforms.")
            NavigationLink("Continue", destination: EmptyView())
        }
    }
}

struct UserSetupActorsView: View {
    var body: some View {
        VStack {
            Text("What are your favorite actors?")
            NavigationLink("Continue", destination: UserSetupStreamingView())
        }
    }
}

struct UserSetupGenreView: View {
    private let movieDb = MovieService()
    @Binding var selection: UserSelection
    @State var genres: [Genre]?

    @Sendable private func loadGenres() async {
        do {
            self.genres = try await movieDb.getGenres()
        } catch {
            print(error)
        }
    }

    var body: some View {
        VStack {
            Text("What are your favorite genres?")
            if let genres = genres {
                List(genres, selection: $selection.genreIDs) { item in
                    Text(item.name)
                }
                .environment(\.editMode, .constant(.active))
            } else {
                ProgressView()
            }
            NavigationLink("Continue", destination: UserSetupActorsView())
        }
        .task(loadGenres)
    }
}

struct UserSelection {
    var genreIDs: Set<Int> = []
    var actorIDs: Set<String> = []
    var serviceIDs: Set<String> = []
}

struct UserSetupView: View {
    @State private var selection = UserSelection()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Let's personalize your experience!")
                Spacer()
                NavigationLink("Continue", destination: UserSetupGenreView(selection: $selection))
            }
        }
    }
}

#Preview {
    UserSetupView()
}
