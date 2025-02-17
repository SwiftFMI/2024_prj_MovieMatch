//
//  ActorsView.swift
//  MovieDate
//
//  Created by Darina Baneva on 13.02.25.
//

//
//  ActorsView.swift
//  MovieDate
//
//  Created by Darina Baneva on 13.02.25.
//

import SwiftUI

struct PersonalizeActorsView: View {
    private let movieSvc = MovieService()
    
    @State private var searchText: String = ""
    @State private var selectedActors: [String] = []
    @State private var searchResults: [Actor] = []

    let exampleActors: [String] = [
        "Leonardo DiCaprio", "Johnny Depp", "Antonio Banderas",
        "Anthony Hopkins", "Angelina Jolie", "Julia Roberts",
        "Margot Robbie", "Cameron Diaz", "Jennifer Aniston"
    ]

    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()

            VStack {
                ProgressView(value: 0.5)
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
                        .onChange(of: searchText) { newValue in
                            fetchActors()
                        }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 20)


                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if !searchText.isEmpty {
                            ForEach(searchResults, id: \.id) { actor in
                                Text(actor.name)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .onTapGesture {
                                        selectActor(actor.name)
                                    }
                            }
                        } else {
                            ForEach(exampleActors + selectedActors, id: \.self) { actor in
                                ActorButton(text: actor, isSelected: selectedActors.contains(actor)) {
                                    toggleActor(actor)
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
    }

    private func fetchActors() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        Task{
            do {
                self.searchResults = try await movieSvc.getActors(query: searchText)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func selectActor(_ actor: String) {
        if !selectedActors.contains(actor) {
            selectedActors.append(actor)
        }
        searchText = ""
        searchResults = []
    }

    private func toggleActor(_ actor: String) {
        if selectedActors.contains(actor) {
            selectedActors.removeAll { $0 == actor }
        } else {
            selectedActors.append(actor)
        }
    }
}

struct ActorButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    PersonalizeActorsView()
        .environmentObject(AuthService.preview)
}
