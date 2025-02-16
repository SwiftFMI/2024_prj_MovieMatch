//
//  LoginView.swift
//  MovieDate
//
//  Created by Darina Baneva on 8.02.25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var email: String = "";
    @State private var password: String = "";

    private func signIn() {
        guard !email.isEmpty && !password.isEmpty else { return }
        Task {
            do {
                try await auth.signIn(email: email, password: password)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var body: some View {
        ZStack {
            Style.appGradient
                .ignoresSafeArea()
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                
                Text("Sign in to continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.bottom, 60)

                TextField("Email", text: $email)
                    .submitLabel(.next)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding()
                    .background(.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                SecureField("Password", text: $password)
                    .submitLabel(.go)
                    .onSubmit(signIn)
                    .padding()
                    .background(.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                Button(action: signIn){
                    Text("Login")
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

                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account?\nCreate one")
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .underline()
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
