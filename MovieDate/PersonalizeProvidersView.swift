//
//  PersonalizeProvidersView.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 16.02.25.
//

import SwiftUI

struct PersonalizeProvidersView: View {
    var body: some View {
        VStack {
            Text("Select your streaming platforms.")
            NavigationLink("Continue", destination: EmptyView())
        }
    }
}

#Preview {
    PersonalizeProvidersView()
}
