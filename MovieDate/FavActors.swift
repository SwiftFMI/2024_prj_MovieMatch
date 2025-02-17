//
//  ActorsView.swift
//  MovieDate
//
//  Created by Darina Baneva on 13.02.25.
//

import SwiftUI

struct ActorsView: View {
    @State private var searchText: String = ""
    @State private var selectedActors: [String] = []
    @State private var searchResults: [Actor] = []

    let apiKey = "e13c8c80bb7b14cf140adb8aa6dd234d"

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

                if !searchText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
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
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                    }
                    .transition(.opacity)
                } else {
                    ScrollView {
                        VStack {
                            ForEach(exampleActors + selectedActors, id: \.self) { actor in
                                ActorButton(text: actor, isSelected: selectedActors.contains(actor)) {
                                    toggleActor(actor)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }

                NavigationLink(destination: EmptyView()) {
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

        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.themoviedb.org/3/search/person?api_key=\(apiKey)&query=\(query)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let response = try JSONDecoder().decode(ActorResponse.self, from: data)
                DispatchQueue.main.async {
                    self.searchResults = response.results
                }
            } catch {
                print("Error decoding: \(error)")
            }
        }.resume()
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

struct Actor: Identifiable, Codable {
    let id: Int
    let name: String
}

struct ActorResponse: Codable {
    let results: [Actor]
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
    ActorsView()
}
