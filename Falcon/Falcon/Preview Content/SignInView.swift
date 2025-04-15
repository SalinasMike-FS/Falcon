//
//  SignInView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .foregroundStyle(.black)
                .padding()
                .frame(height: 60)
                .background(Color(.systemGray6))
                .border(.fill, width: 2).foregroundColor(.black)
                .cornerRadius(10)

            TextField("Password", text: $password)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .frame(height: 60)
                .background(Color(.systemGray6))
                .border(.fill, width: 2).foregroundColor(.black)
                .cornerRadius(10)
               

            Spacer()
            VStack(spacing: 16) {
                Button("Reset Password") {
                    // Implement password reset functionality here
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

                Button("Login") {
                    // Authenticate with Firestore
                    // Auth.auth().signIn(withEmail: email, password: password) { result, error in ... }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.red)
            .padding(.top, 30)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SignInView()
}
