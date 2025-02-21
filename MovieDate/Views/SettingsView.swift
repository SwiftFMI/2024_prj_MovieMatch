//
//  SettingsView.swift
//  MovieDate
//
//  Created by Darina Baneva on 17.02.25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var authSvc: AuthService
    @EnvironmentObject private var userSvc: UserService
    @EnvironmentObject private var partnerSvc: UserPartnerService

    var body: some View {
        List {
            if let user = userSvc.user {
                Section(header: Text("User")) {
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(user.email)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
            }
            
            Section(header: Text("Personalize")) {
                VStack(alignment: .leading) {
                    Text("Personalize your experience again.")
                        .foregroundColor(.gray)
                        .font(.subheadline)

                    Button(action: {
                        userSvc.setPersonalizeDone(value: false)
                    }) {
                        Text("Personalize")
                            .frame(maxWidth: .infinity)
                            .padding(5)
                    }
                    .buttonStyle(.bordered)
                }
            }

            if let partner = partnerSvc.mutualPartner {
                Section(header: Text("Partner")) {
                    VStack(alignment: .leading) {
                        Text(partner.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(partner.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            partnerSvc.setPartner(uid: nil)
                        }) {
                            Text("Remove Partner")
                                .frame(maxWidth: .infinity)
                                .padding(5)
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
            }
            
            Section(header: Text("Actions")) {
                Button(action: {
                    try? authSvc.signOut()
                }) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                        .padding(5)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isPresented = false }) {
                    Text("Done")
                }
            }
        }
    }
}

#Preview {
    SettingsView(isPresented: .constant(true))
        .environmentObject(PreviewCompose.authSvc)
        .environmentObject(PreviewCompose.userSvc)
        .environmentObject(PreviewCompose.userPartnerSvc)
}
