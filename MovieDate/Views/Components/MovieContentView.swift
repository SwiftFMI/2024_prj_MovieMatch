//
//  MovieContentView.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 21.02.25.
//

import SwiftUI

struct MovieContentView: View {
    let movie: MovieDetails

    var body: some View {
        VStack {
            Text(movie.titleFull)
                .multilineTextAlignment(.center)
                .font(.title2)
                .bold()
                .padding(.top, 5)

            Text(movie.overview)
                .font(.body)
                .padding(.vertical)

            HStack {
                Text("Rating")
                    .font(.title3)
                    .bold()
                Text("\(String(format: "%.1f", movie.vote_average))/10")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Text("Released")
                    .font(.title3)
                    .bold()
                Text(movie.release_date)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack {
                Text("Cast")
                    .padding(.vertical)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                PeopleView(people: movie.credits.castSelection)
            }

            VStack {
                Text("Crew")
                    .padding(.vertical)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                PeopleView(people: movie.credits.crewSelection)
            }

            VStack {
                Text("Watch")
                    .padding(.vertical)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                ProvidersView(providers: movie.providers)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
    }
}

fileprivate struct PeopleView: View {
    let people: [Person]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(people.prefix(10)) { p in
                    VStack {
                        AsyncImage(url: p.profileUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        Text(p.name)
                            .multilineTextAlignment(.center)
                        if let job = p.job {
                            Text(job)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(width: 100)
                    .padding(.horizontal, 5)
                }
            }
        }
    }
}

fileprivate struct ProvidersView: View {
    let providers: MovieWatchProviders

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(providers.local?.allUnique ?? []) { p in
                    VStack {
                        AsyncImage(url: p.logoUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 80, height: 80)
                        Text(p.name)
                    }
                }
            }
        }
    }
}
