//
//  ContentView.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 3.01.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                    .foregroundStyle(.white)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
