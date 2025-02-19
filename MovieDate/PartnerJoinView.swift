//
//  PartnerJoinView.swift
//  MovieDate
//
//  Created by Darina Baneva on 8.02.25.
//

import SwiftUI

struct PartnerJoinView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var name: String = "";

    var body: some View {
        ZStack {
            Style.appGradient
            VStack {
                Text("Add Your Partner")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                
                TextField("Partner Name", text: $name)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                Button(action: {
                    Task {
                        await auth.trySetPartner(name: name)
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
                
                if let user = auth.user {
                    Text(user.name)
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.7))
                        .fontWeight(.bold)
                }

                if auth.pendingPartners.isEmpty {
                    ProgressView().colorScheme(.dark)
                        .padding()

                } else {
                    ForEach(auth.pendingPartners) { partner in
                        SelectableButton(text: partner.name) {
                            auth.setPartner(uid: partner.uid)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PartnerJoinView()
        .environmentObject(AuthService.preview)
}
