//
//  PartnerJoinView.swift
//  MovieDate
//
//  Created by Darina Baneva on 8.02.25.
//

import SwiftUI

struct PartnerJoinView: View {
    @EnvironmentObject private var authSvc: AuthService
    @EnvironmentObject private var userSvc: UserService
    @EnvironmentObject private var userPartnerSvc: UserPartnerService
    @State private var name: String = "";

    var body: some View {
        ZStack {
            AppGradient()
            VStack {
                Text("Add Your Partner")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                
                TextField("Partner Name", text: $name)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTextFieldBackground())
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                Button(action: {
                    Task {
                        await userPartnerSvc.trySetPartner(name: name)
                    }
                }){
                    Text("Send Invite")
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

                Divider()
                    .frame(minHeight: 2)
                    .overlay(.white.opacity(0.5))
                    .padding()
                    .padding(.vertical, 40)

                Text("Your Invites")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                
                if let user = userSvc.user {
                    Text(user.name)
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.7))
                        .fontWeight(.bold)
                }

                if userPartnerSvc.pendingPartners.isEmpty {
                    ProgressView().colorScheme(.dark)
                        .padding()

                } else {
                    ForEach(userPartnerSvc.pendingPartners) { partner in
                        SelectableButton(text: partner.name) {
                            userPartnerSvc.setPartner(uid: partner.uid)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { try? authSvc.signOut() }) {
                    Text("Sign Out")
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    PartnerJoinView()
        .environmentObject(PreviewCompose.authSvc)
        .environmentObject(PreviewCompose.userSvc)
        .environmentObject(PreviewCompose.userPartnerSvc)
}
