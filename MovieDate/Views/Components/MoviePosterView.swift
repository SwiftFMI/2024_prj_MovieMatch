//
//  MoviePosterView.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 21.02.25.
//


import SwiftUI

struct MoviePosterView: View {
    let posterURL: URL

    var body: some View {
        ZStack {
            Rectangle().fill(.black)
                .frame(maxWidth: .infinity)
                .aspectRatio(2/3, contentMode: .fit)
            AsyncImage(url: posterURL) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            } placeholder: {
                ProgressView()
            }
        }
        .cornerRadius(20)
    }
}
