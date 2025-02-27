//
//  LoginView.swift
//  MovieDate
//
//  Created by Darina Baneva on 8.02.25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var authSvc: AuthService
    @EnvironmentObject private var userSvc: UserService
    @State private var email: String = "";
    @State private var password: String = "";

    private func signIn() {
        guard !email.isEmpty && !password.isEmpty else { return }
        Task {
            do {
                try await authSvc.signIn(email: email, password: password)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var body: some View {
        ZStack {
            AppGradient()
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
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTextFieldBackground())
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                SecureField("Password", text: $password)
                    .submitLabel(.go)
                    .onSubmit(signIn)
                    .padding()
                    .background(AppTextFieldBackground())
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
