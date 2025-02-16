//
//  ActorsView.swift
//  MovieDate
//
//  Created by Darina Baneva on 13.02.25.
//

import SwiftUI

struct PersonalizeActorsView: View {
    var body: some View {
        VStack {
            Text("What are your favorite actors?")
            NavigationLink("Continue", destination: PersonalizeProvidersView())
        }
    }
}

#Preview {
    PersonalizeActorsView()
}
