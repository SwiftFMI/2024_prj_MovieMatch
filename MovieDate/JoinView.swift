//
//  JoinView.swift
//  MovieDate
//
//  Created by Darina Baneva on 8.02.25.
//

import SwiftUI

struct JoinView: View {
    @State private var code: String = "";

    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()
            VStack {
                Text("Add Your Partner")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                
                TextField("Partner code", text: $code)
                    .padding()
                    .background(.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                Button(action: {
                    
                }){
                    Text("Confirm")
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

                Text("Your Code")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)

                Text("D546F8")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.7))
                    .fontWeight(.bold)
                    .padding()
            }
        }
    }
}

#Preview {
    JoinView()
}
