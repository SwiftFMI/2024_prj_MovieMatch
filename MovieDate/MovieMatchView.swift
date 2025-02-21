//
//  MovieMatchView.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 21.02.25.
//


import SwiftUI

struct MovieMatchView: View {
    @Binding var movie: MovieDetails?

    var body: some View {
        ZStack {
            Style.appGradient

            VStack {
                Text("🎉")
                    .font(.largeTitle.bold())
                Text("It's a Match!")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle.bold())
                    .padding(10)

                VStack {
                    if let movie {
                        if let posterURL = movie.posterURL {
                            AsyncImage(url: posterURL) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(maxWidth: .infinity)
                        }
                        Text("\(movie.title) (\(movie.year))")
                            .padding(.top, 10)
                            .font(.title2)
                            .bold()
                    }
                }
                .padding(.bottom, 40)

                Spacer()

                Button(action: { movie = nil }) {
                    Text("Continue")
                        .padding()
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 1)
                        )
                }
            }
            .padding(40)
        }
    }
}