//
//  SignUpView.swift
//  MovieDate
//
//  Created by Darina Baneva on 8.02.25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authSvc: AuthService
    @EnvironmentObject private var userSvc: UserService
    @State private var name: String = "";
    @State private var email: String = "";
    @State private var password: String = "";

    private func signUp() {
        guard !email.isEmpty && !password.isEmpty && !name.isEmpty else { return }
        Task {
            do {
                try await authSvc.signUp(name: name, email: email, password: password)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var body: some View {
        ZStack {
            AppGradient()
            VStack {
                Text("Create New Account")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTextFieldBackground())
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTextFieldBackground())
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                
                SecureField("Password", text: $password)
                    .submitLabel(.go)
                    .onSubmit(signUp)
                    .padding()
                    .background(AppTextFieldBackground())
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)

                Button(action: signUp){
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
