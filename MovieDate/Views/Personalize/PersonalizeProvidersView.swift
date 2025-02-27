//
//  PersonalizeProvidersView.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 16.02.25.
//

import SwiftUI

struct PersonalizeProvidersView: View {
    private let movieSvc = AppCompose.movieSvc

    @EnvironmentObject private var userSvc: UserService
    @State private var providers: [WatchProvider] = []

    var body: some View {
        ZStack {
            AppGradient()
            
            VStack {
                ProgressView(value: 3.0/3)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 150)
                    .padding(.top, 20)
                    .tint(.red)
                
                Text("Select your streaming platforms.")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                ScrollView {
                    VStack {
                        ForEach(providers) { provider in
                            if let user = userSvc.user {
                                let isSelected = user.selectedProviders.contains(provider.id) == true
                                let icon = AsyncImage(url: provider.logoUrl) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .frame(width: 40, height: 40)
                                } placeholder: {
                                    ProgressView().colorScheme(.dark)
                                        .frame(width: 40, height: 40)
                                }
                                SelectableButton(icon: icon, text: provider.name, isSelected: isSelected) {
                                    userSvc.updateUserSelect(key: .selectedProviders, id: provider.id, isSelected: !isSelected)
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                }

                Button(action: finishPersonalize) {
                    Text("Finish")
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
        .onAppear(perform: fetchProviders)
    }

    private func fetchProviders() {
        Task {
            do {
                self.providers = try await movieSvc.getProviders()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func finishPersonalize() {
        userSvc.setPersonalizeDone(value: true)
    }
}

#Preview {
    PersonalizeProvidersView()
        .environmentObject(PreviewCompose.userSvc)
}
