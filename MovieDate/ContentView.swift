//
//  ContentView.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 3.01.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                if let user = auth.user {
                    Text("Hello, \(user.name)")
                        .foregroundStyle(.white)
                } else {
                    ProgressView()
                }

                Button(action: {
                    do {
                        try auth.signOut()
                    } catch {
                        print(error.localizedDescription)
                    }
                }) {
                    Text("Logout")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.preview)
}
