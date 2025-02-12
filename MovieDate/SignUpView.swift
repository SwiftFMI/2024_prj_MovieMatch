//
//  SignUpView.swift
//  MovieDate
//
//  Created by Darina Baneva on 8.02.25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var name: String = "";
    @State private var email: String = "";
    @State private var password: String = "";

    private func signUp() async throws {
        guard !email.isEmpty && !password.isEmpty else { return }
        try await auth.signUp(email: email, password: password)
    }

    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()
            VStack {
                Text("Create New Account")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                
                TextField("Name", text: $name)
                    .padding()
                    .background(.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding()
                    .background(.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                Button(action: {
                    Task {
                        do {
                            try await signUp()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }){
                    Text("Sign Up")
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
            }
        }
    }
}

#Preview {
    SignUpView()
}
