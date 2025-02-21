//
//  ActorsView.swift
//  MovieDate
//
//  Created by Darina Baneva on 13.02.25.
//

import SwiftUI

struct PersonalizeActorsView: View {
    private let movieSvc = AppCompose.movieSvc

    @EnvironmentObject private var userSvc: UserService
    @State private var searchText: String = ""
    @State private var searchResults: [Person] = []
    @State private var selectedActors: [Person] = []

    private let exampleActors: [Int] = [
        6193, //"Leonardo DiCaprio",
        85, //"Johnny Depp",
        3131, // "Antonio Banderas",
        4173, //"Anthony Hopkins",
        11701, //"Angelina Jolie",
        1204, //"Julia Roberts",
        234352, //"Margot Robbie",
        6941, //"Cameron Diaz",
        4491, //"Jennifer Aniston",
    ]

    var body: some View {
        ZStack {
            AppGradient()

            VStack {
                ProgressView(value: 2.0/3)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 150)
                    .tint(.red)

                Text("Who are your favorite actors?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)

               
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("", text: $searchText)
                        .foregroundColor(.white)
                        .onChange(of: searchText, fetchSearch)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 20)


                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        let actors = !searchText.isEmpty
                            ? searchResults
                            : selectedActors

                        ForEach(actors) { actor in
                            if let user = userSvc.user {
                                let isSelected = user.selectedActors.contains(actor.id) == true
                                SelectableButton(text: actor.name, isSelected: isSelected) {
                                    userSvc.updateUserSelect(key: .selectedActors, id: actor.id, isSelected: !isSelected)
                                    if !searchText.isEmpty {
                                        searchText = ""
                                        searchResults = []
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                }
                .transition(.opacity)

                NavigationLink(destination: PersonalizeProvidersView()) {
                    Text("Continue")
                        .padding()
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
        }
        .onAppear(perform: fetchActors)
        .onChange(of: userSvc.user?.selectedActors, fetchActors)
    }

    private func fetchActors() {
        let selected = self.userSvc.user?.selectedActors ?? []
        let ids = exampleActors + selected.filter{ !exampleActors.contains($0) }
        Task {
            await withTaskGroup(of: (Int, Person?).self) { group in
                for (i, id) in ids.enumerated() {
                    group.addTask {
                        return (i, try? await movieSvc.getPerson(id: id))
                    }
                }
                var results: [Person?] = Array(repeating: nil, count: ids.count)
                for await (i, res) in group {
                    results[i] = res
                }
                self.selectedActors = results.compactMap{ $0 }
            }
        }
    }

    private func fetchSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        Task{
            do {
                self.searchResults = try await movieSvc.searchPeople(query: searchText)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    PersonalizeActorsView()
        .environmentObject(PreviewCompose.userSvc)
}
